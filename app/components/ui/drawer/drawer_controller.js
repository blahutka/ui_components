import { Controller } from "@hotwired/stimulus"

// Behaviour for UI::Drawer (Base UI's Drawer in Appica's React version).
//
// The panel is a native <dialog>: showModal() puts it in the top layer, makes the
// page behind it inert, and turns Escape into a `cancel` event. On top of that this
// controller adds the enter/exit animations (data-starting-style / data-ending-style),
// scroll locking, swipe-to-dismiss, snap points and the stacked look of nested drawers,
// driven by the same CSS variables the Appica classes read (--drawer-swipe-movement-*,
// --drawer-swipe-progress, --nested-drawers).
//
// Emits `ui--drawer:open-change` with { open } (React's onOpenChange) and
// `ui--drawer:snap-point-change` with { snapPoint }.
const SWIPE_THRESHOLD = 5            // px before a press becomes a swipe
const DISMISS_FRACTION = 0.4         // share of the panel dragged past to dismiss
const DISMISS_VELOCITY = 0.5         // px/ms flick that dismisses regardless of distance
const INTERACTIVE = "button, a, input, textarea, select, label, [contenteditable], [role=slider]"

let scrollLocks = 0

export default class extends Controller {
  static targets = [ "trigger", "dialog", "backdrop", "popup", "content", "body" ]
  static values = {
    side: { type: String, default: "bottom" },
    modal: { type: Boolean, default: true },
    open: Boolean,
    dismissible: { type: Boolean, default: true },
    snapPoints: Array
  }

  connect() {
    this.snapOffset = 0
    this.removeMissingDescriptions()
    if (this.openValue) this.open()
  }

  disconnect() {
    if (this.isOpen) this.unlockScroll()
  }

  // Actions

  open() {
    if (this.isOpen) return

    const dialog = this.dialogTarget
    this.modalValue ? dialog.showModal() : dialog.show()
    if (this.modalValue) this.lockScroll()

    this.setOpenState(true)
    this.measureSnapPoints()
    this.parentController?.nestedChanged(1)

    this.animate("data-starting-style", () => {})
    this.dispatch("open-change", { detail: { open: true } })
  }

  close() {
    if (!this.isOpen || this.closing) return
    this.closing = true

    this.setOpenState(false)
    this.parentController?.nestedChanged(-1)
    this.setMovement(this.dismissDistance)

    this.animate("data-ending-style", () => {
      this.dialogTarget.close()
      this.resetMovement()
      if (this.modalValue) this.unlockScroll()
      this.closing = false
      this.triggerTargets[0]?.focus({ preventScroll: true })
    })
    this.dispatch("open-change", { detail: { open: false } })
  }

  // Escape on the topmost dialog
  cancel(event) {
    event.preventDefault()
    this.close()
  }

  // Clicks on the backdrop or the empty viewport around the panel
  dismiss(event) {
    const outside = event.target === this.dialogTarget || (this.hasBackdropTarget && event.target === this.backdropTarget)
    if (outside && this.dismissibleValue && !this.swipedRecently) this.close()
  }

  // Called by a nested drawer's controller when it opens (+1) or closes (-1)
  nestedChanged(delta) {
    this.nestedCount = Math.max(0, (this.nestedCount || 0) + delta)
    this.popupTarget.style.setProperty("--nested-drawers", this.nestedCount)
    this.popupTarget.toggleAttribute("data-nested-drawer-open", this.nestedCount > 0)
    if (this.isVertical) this.popupTarget.style.setProperty("--drawer-frontmost-height", `${this.popupTarget.offsetHeight}px`)
  }

  // Swipe to dismiss / drag between snap points

  swipeStart(event) {
    if (event.button !== 0 || !this.isOpen || event.target.closest(INTERACTIVE)) return
    if (this.startsInScrollableBody(event)) return

    this.swipe = {
      pointerId: event.pointerId,
      startX: event.clientX,
      startY: event.clientY,
      lastPosition: this.isVertical ? event.clientY : event.clientX,
      lastTime: event.timeStamp,
      velocity: 0,
      distance: 0,
      active: false
    }

    this.onSwipeMove = this.swipeMove.bind(this)
    this.onSwipeEnd = this.swipeEnd.bind(this)
    window.addEventListener("pointermove", this.onSwipeMove)
    window.addEventListener("pointerup", this.onSwipeEnd)
    window.addEventListener("pointercancel", this.onSwipeEnd)
  }

  swipeMove(event) {
    const swipe = this.swipe
    if (!swipe || event.pointerId !== swipe.pointerId) return

    const deltaX = event.clientX - swipe.startX
    const deltaY = event.clientY - swipe.startY
    const along = this.isVertical ? deltaY : deltaX
    const across = this.isVertical ? deltaX : deltaY

    if (!swipe.active) {
      if (Math.abs(along) < SWIPE_THRESHOLD) return
      if (Math.abs(across) > Math.abs(along)) return this.swipeEnd(event)

      swipe.active = true
      this.popupTarget.setPointerCapture?.(event.pointerId)
      this.setSwiping(true)
    }

    const position = this.isVertical ? event.clientY : event.clientX
    const elapsed = Math.max(1, event.timeStamp - swipe.lastTime)
    swipe.velocity = ((position - swipe.lastPosition) * this.direction) / elapsed
    swipe.lastPosition = position
    swipe.lastTime = event.timeStamp

    // Distance travelled towards the edge; pulling the other way rubber-bands
    let distance = this.snapOffset + along * this.direction
    if (distance < 0) distance = -Math.sqrt(-distance) * 2
    swipe.distance = distance

    this.setMovement(distance)
  }

  swipeEnd() {
    const swipe = this.swipe
    window.removeEventListener("pointermove", this.onSwipeMove)
    window.removeEventListener("pointerup", this.onSwipeEnd)
    window.removeEventListener("pointercancel", this.onSwipeEnd)
    this.swipe = null
    if (!swipe?.active) return

    this.setSwiping(false)
    this.swipedRecently = true
    setTimeout(() => { this.swipedRecently = false }, 0)

    if (this.snapPoints.length > 0) {
      this.settleOnSnapPoint(swipe)
    } else if (swipe.distance > this.panelSize * DISMISS_FRACTION || swipe.velocity > DISMISS_VELOCITY) {
      this.close()
    } else {
      this.setMovement(0)
    }
  }

  // Snap points (top/bottom drawers): resting heights as a fraction of the
  // viewport (0-1), pixels (> 1) or a CSS length string ("24rem")

  measureSnapPoints() {
    if (!this.isVertical || this.snapPointsValue.length === 0) {
      this.snapPoints = []
      return
    }

    const available = this.dialogTarget.clientHeight - 16
    const heights = this.snapPointsValue.map(point => Math.min(available, this.resolveLength(point, available)))
    const full = Math.max(...heights)

    this.popupTarget.style.setProperty("--drawer-height", `${full}px`)
    this.snapPoints = this.snapPointsValue.map((value, index) => ({ value, offset: full - heights[index] }))
    this.moveToSnapPoint(this.snapPoints[0])
  }

  settleOnSnapPoint(swipe) {
    const projected = swipe.distance + swipe.velocity * 200
    const lowest = Math.max(...this.snapPoints.map(point => point.offset))
    const lowestHeight = this.panelSize - lowest

    if (projected > lowest + lowestHeight * 0.5) return this.close()

    const nearest = this.snapPoints.reduce((best, point) =>
      Math.abs(point.offset - projected) < Math.abs(best.offset - projected) ? point : best)
    this.moveToSnapPoint(nearest)
  }

  moveToSnapPoint(point) {
    this.snapOffset = point.offset
    this.setMovement(point.offset)
    this.dispatch("snap-point-change", { detail: { snapPoint: point.value } })
  }

  resolveLength(value, available) {
    if (typeof value === "number") return value <= 1 ? value * available : value

    const probe = document.createElement("div")
    probe.style.cssText = `position:absolute;visibility:hidden;height:${value}`
    this.dialogTarget.append(probe)
    const height = probe.getBoundingClientRect().height
    probe.remove()
    return height
  }

  // State

  get isOpen() {
    return this.hasDialogTarget && this.dialogTarget.open
  }

  get isVertical() {
    return this.sideValue === "top" || this.sideValue === "bottom"
  }

  // +1 when dismissing moves along the positive axis (right, bottom)
  get direction() {
    return this.sideValue === "right" || this.sideValue === "bottom" ? 1 : -1
  }

  get panelSize() {
    const rect = this.popupTarget.getBoundingClientRect()
    return this.isVertical ? rect.height : rect.width
  }

  get dismissDistance() {
    return this.panelSize + 8
  }

  get parentController() {
    const parent = this.element.parentElement?.closest("[data-controller~='ui--drawer']")
    return parent && this.application.getControllerForElementAndIdentifier(parent, "ui--drawer")
  }

  setOpenState(open) {
    const elements = [ this.dialogTarget, this.popupTarget, ...this.backdropTargets ]
    elements.forEach(element => element.toggleAttribute("data-open", open))
    this.triggerTargets.forEach(trigger => {
      trigger.setAttribute("aria-expanded", open)
      trigger.toggleAttribute("data-popup-open", open)
    })
  }

  setSwiping(swiping) {
    [ this.popupTarget, ...this.backdropTargets ].forEach(element => element.toggleAttribute("data-swiping", swiping))
    this.parentController?.popupTarget.toggleAttribute("data-nested-drawer-swiping", swiping)
  }

  // Moves the panel `distance` px towards its edge and fades the backdrop to match
  setMovement(distance) {
    const property = this.isVertical ? "--drawer-swipe-movement-y" : "--drawer-swipe-movement-x"
    const size = this.panelSize || 1
    const progress = Math.min(1, Math.max(0, (distance - this.snapOffset) / size))

    this.popupTarget.style.setProperty(property, `${distance * this.direction}px`)
    this.popupTarget.style.setProperty("--drawer-swipe-progress", progress)
    this.backdropTargets.forEach(backdrop => backdrop.style.setProperty("--drawer-swipe-progress", progress))
    this.parentController?.popupTarget.style.setProperty("--drawer-swipe-progress", progress)
  }

  resetMovement() {
    this.snapOffset = 0
    this.popupTarget.style.setProperty("--drawer-swipe-movement-x", "0px")
    this.popupTarget.style.setProperty("--drawer-swipe-movement-y", "0px")
    this.popupTarget.style.setProperty("--drawer-swipe-progress", 0)
    this.popupTarget.style.removeProperty("--drawer-height")
    this.backdropTargets.forEach(backdrop => backdrop.style.setProperty("--drawer-swipe-progress", 0))
    this.parentController?.popupTarget.style.setProperty("--drawer-swipe-progress", 0)
  }

  // Sets a transition state attribute on the popup and backdrop; for the starting
  // style it's removed on the next frame, for the ending style once the exit ends
  animate(attribute, done) {
    const elements = [ this.popupTarget, ...this.backdropTargets ]

    if (attribute === "data-starting-style") {
      // Commit the starting styles, then drop them so the panel transitions in.
      // (A forced style flush instead of requestAnimationFrame, which stalls in background tabs.)
      elements.forEach(element => element.setAttribute(attribute, ""))
      elements.forEach(element => getComputedStyle(element).transform)
      elements.forEach(element => element.removeAttribute(attribute))
      return done()
    }

    elements.forEach(element => element.setAttribute(attribute, ""))
    const finish = () => {
      clearTimeout(this.exitTimer)
      this.popupTarget.removeEventListener("transitionend", onEnd)
      elements.forEach(element => element.removeAttribute(attribute))
      done()
    }
    const onEnd = event => { if (event.target === this.popupTarget && event.propertyName === "transform") finish() }

    if (this.prefersReducedMotion) return finish()
    this.popupTarget.addEventListener("transitionend", onEnd)
    this.exitTimer = setTimeout(finish, 450)
  }

  // Helpers

  startsInScrollableBody(event) {
    const body = event.target.closest("[data-slot='drawer-body']")
    if (!body || !this.isVertical) return false
    return body.scrollHeight > body.clientHeight
  }

  lockScroll() {
    if (scrollLocks++ === 0) {
      const scrollbar = window.innerWidth - document.documentElement.clientWidth
      document.documentElement.style.overflow = "hidden"
      document.documentElement.style.paddingRight = scrollbar > 0 ? `${scrollbar}px` : ""
    }
  }

  unlockScroll() {
    if (--scrollLocks <= 0) {
      scrollLocks = 0
      document.documentElement.style.overflow = ""
      document.documentElement.style.paddingRight = ""
    }
  }

  removeMissingDescriptions() {
    const dialog = this.dialogTarget
    for (const attribute of [ "aria-labelledby", "aria-describedby" ]) {
      const id = dialog.getAttribute(attribute)
      if (id && !dialog.querySelector(`#${CSS.escape(id)}`)) dialog.removeAttribute(attribute)
    }
  }

  get prefersReducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }
}
