import { Controller } from "@hotwired/stimulus"

// AppicaUI::NavigationMenu: opens an item's panel on hover (after `delay`), click or the keyboard,
// moves the panel from its item into the popup (top layer) or the inline viewport, positions the
// popup under the trigger (beside it when vertical) and morphs it between panels, closes on
// leave (after `closeDelay`), Escape, focus leaving or a click outside. Nested menus inside a
// panel are separate controllers. Emits `appica-ui--navigation-menu:change` with { value } (null when closed).
export default class extends Controller {
  static targets = [ "list", "item", "trigger", "content", "popup", "viewport", "backdrop", "barLink" ]
  static values = { delay: { type: Number, default: 50 }, closeDelay: { type: Number, default: 50 }, sideOffset: { type: Number, default: 6 },
    orientation: String, inline: Boolean, defaultValue: String }

  connect() {
    this.onOutside = event => { if (!this.element.contains(event.target)) this.close() }
    this.onReflow = () => this.position()
    if (this.defaultValueValue) this.open(this.defaultValueValue)
  }

  disconnect() {
    this.clearTimers()
    this.close({ immediate: true })
  }

  // Pointer

  hover(event) {
    if (event.pointerType === "touch") return
    const value = event.currentTarget.dataset.value
    this.clearTimers()
    if (this.current === value) return
    this.openTimer = setTimeout(() => this.open(value), this.current ? 0 : this.delayValue)
  }

  enter() {
    clearTimeout(this.closeTimer)
  }

  leave(event) {
    if (event.pointerType === "touch" || this.inlineValue) return
    clearTimeout(this.openTimer)
    this.closeTimer = setTimeout(() => this.close(), this.closeDelayValue)
  }

  toggle(event) {
    const value = event.currentTarget.dataset.value
    if (this.current === value && !this.inlineValue) this.close()
    else this.open(value)
  }

  // Keyboard: the arrow toward the panel opens it and focuses its first link; ←/→ (↑/↓) move
  // between the bar's items; Escape closes back to the trigger
  key(event) {
    const vertical = this.orientationValue === "vertical"
    const rtl = getComputedStyle(this.element).direction === "rtl"
    const trigger = this.triggerTargets.find(trigger => trigger === event.target)
    const inBar = trigger || this.barLinkTargets.includes(event.target)
    const intoPanel = vertical ? (rtl ? "ArrowLeft" : "ArrowRight") : "ArrowDown"

    if (event.key === "Escape" && this.current) {
      event.preventDefault()
      event.stopPropagation()
      const opener = this.triggerFor(this.current)
      this.close()
      opener?.focus()
    } else if (trigger && event.key === intoPanel) {
      event.preventDefault()
      this.open(trigger.dataset.value)
      requestAnimationFrame(() => this.focusable(this.contentFor(trigger.dataset.value))[0]?.focus())
    } else if (inBar && [ "ArrowLeft", "ArrowRight", "ArrowUp", "ArrowDown", "Home", "End" ].includes(event.key)) {
      const keys = vertical ? { ArrowUp: -1, ArrowDown: 1 } : { ArrowLeft: rtl ? 1 : -1, ArrowRight: rtl ? -1 : 1 }
      const items = this.barItems
      const index = items.indexOf(event.target)
      let next
      if (event.key in keys) next = (index + keys[event.key] + items.length) % items.length
      else if (event.key === "Home") next = 0
      else if (event.key === "End") next = items.length - 1
      else return
      event.preventDefault()
      items[next]?.focus()
    }
  }

  focusOut(event) {
    if (this.inlineValue || !this.current) return
    if (event.relatedTarget && this.element.contains(event.relatedTarget)) return
    this.close()
  }

  // Open / close

  open(value) {
    const content = this.contentFor(value)
    const trigger = this.triggerFor(value)
    if (!content || trigger?.disabled) return
    const previous = this.current
    if (previous === value) return

    this.clearTimers()
    if (previous) this.restore(this.contentFor(previous))
    this.current = value
    this.triggerTargets.forEach(other => {
      const open = other === trigger
      other.toggleAttribute("data-popup-open", open)
      other.setAttribute("aria-expanded", open)
    })

    const viewport = this.hasViewportTarget ? this.viewportTarget : null
    if (viewport) {
      content.homeParent ??= content.parentElement
      viewport.append(content)
    }
    content.hidden = false
    if (previous) {
      content.setAttribute("data-starting-style", "")
      requestAnimationFrame(() => content.removeAttribute("data-starting-style"))
    }

    if (this.hasPopupTarget) this.show()
    this.dispatch("change", { detail: { value } })
  }

  close({ immediate = false } = {}) {
    if (!this.current || this.inlineValue && !immediate) return
    const content = this.contentFor(this.current)
    this.current = null
    this.triggerTargets.forEach(trigger => {
      trigger.removeAttribute("data-popup-open")
      trigger.setAttribute("aria-expanded", "false")
    })
    this.hide({ immediate, after: () => this.restore(content) })
    if (!this.hasPopupTarget) this.restore(content)
    this.dispatch("change", { detail: { value: null } })
  }

  // Back into its item, hidden
  restore(content) {
    if (!content) return
    content.hidden = true
    if (content.homeParent && content.parentElement !== content.homeParent) content.homeParent.append(content)
  }

  show() {
    const popup = this.popupTarget
    const opening = !popup.matches(":popover-open")
    if (opening) {
      popup.removeAttribute("data-ending-style")
      popup.setAttribute("data-instant", "")
      popup.showPopover()
      popup.setAttribute("data-starting-style", "")
      document.addEventListener("pointerdown", this.onOutside, true)
      window.addEventListener("resize", this.onReflow)
      window.addEventListener("scroll", this.onReflow, true)
      this.backdropTargets.forEach(backdrop => backdrop.setAttribute("data-open", ""))
    }
    this.position()
    // The first placement jumps; later ones (switching panels) morph
    requestAnimationFrame(() => {
      popup.removeAttribute("data-starting-style")
      requestAnimationFrame(() => popup.removeAttribute("data-instant"))
    })
  }

  hide({ immediate, after }) {
    if (!this.hasPopupTarget) return after()
    const popup = this.popupTarget
    document.removeEventListener("pointerdown", this.onOutside, true)
    window.removeEventListener("resize", this.onReflow)
    window.removeEventListener("scroll", this.onReflow, true)
    this.backdropTargets.forEach(backdrop => backdrop.removeAttribute("data-open"))
    if (!popup.matches(":popover-open")) return after()

    const finish = () => {
      if (this.current) return // reopened meanwhile
      popup.removeAttribute("data-ending-style")
      popup.hidePopover()
      after()
    }
    const duration = parseFloat(getComputedStyle(popup).transitionDuration) || 0
    if (immediate || !duration) return finish()
    popup.setAttribute("data-ending-style", "")
    setTimeout(finish, 160)
  }

  // Under the trigger (start-aligned), or beside it when vertical; sized to the panel
  position() {
    if (!this.current || !this.hasPopupTarget) return
    const popup = this.popupTarget
    const trigger = this.triggerFor(this.current)
    const content = this.contentFor(this.current)
    if (!trigger || !content) return

    const rtl = getComputedStyle(this.element).direction === "rtl"
    const rect = trigger.getBoundingClientRect()
    const border = popup.offsetWidth - popup.clientWidth
    const width = content.scrollWidth + border
    const height = content.scrollHeight + border
    const offset = this.sideOffsetValue
    const margin = 8
    let top
    let left

    if (this.orientationValue === "vertical") {
      top = rect.top
      left = rtl ? rect.left - offset - width : rect.right + offset
      if (!rtl && left + width > window.innerWidth - margin) left = rect.left - offset - width
      if (rtl && left < margin) left = rect.right + offset
    } else {
      top = rect.bottom + offset
      left = rtl ? rect.right - width : rect.left
    }
    left = Math.max(margin, Math.min(left, window.innerWidth - width - margin))
    top = Math.max(margin, Math.min(top, window.innerHeight - height - margin))

    Object.assign(popup.style, { top: `${top}px`, left: `${left}px`, width: `${width}px`, height: `${height}px` })
    popup.style.transformOrigin = this.orientationValue === "vertical" ? (rtl ? "right top" : "left top") : (rtl ? "right top" : "left top")
  }

  // Helpers

  clearTimers() {
    clearTimeout(this.openTimer)
    clearTimeout(this.closeTimer)
  }

  contentFor(value) {
    return this.contentTargets.find(content => content.dataset.value === value)
  }

  triggerFor(value) {
    return this.triggerTargets.find(trigger => trigger.dataset.value === value)
  }

  focusable(container) {
    return container ? [ ...container.querySelectorAll("a[href], button:not([disabled]), input, [tabindex]:not([tabindex='-1'])") ] : []
  }

  // Triggers and bar links in reading order (not the ones inside panels)
  get barItems() {
    return [ ...this.triggerTargets, ...this.barLinkTargets ]
      .filter(element => !element.disabled)
      .sort((a, b) => a.compareDocumentPosition(b) & Node.DOCUMENT_POSITION_FOLLOWING ? -1 : 1)
  }
}
