import { Controller } from "@hotwired/stimulus"
import { placeFloating } from "appica_ui/floating"

// The floating surface behind AppicaUI::Popover, AppicaUI::PreviewCard and AppicaUI::Tooltip: a popup in the top
// layer placed against its trigger (flip, shift, arrow), opened by click and / or hover / focus
// with delays, closed on Escape, a click outside, leaving (hover) or blurring (focus).
//
// Values: `click` (toggle on click), `hover` (open on pointer rest after `delay`, close
// `closeDelay` after leaving trigger and popup), `focus` (open on keyboard focus), `interactive`
// (focus moves into the popup and the pointer may enter it), `track` ("x" / "y" / "both":
// follow the pointer), `closeOnClick` (a click on the trigger closes it - tooltips). The trigger
// may carry data-hover / data-delay / data-close-delay, and the popup data-side / data-align /
// data-side-offset / data-align-offset, overriding these.
// A tooltip provider ([data-slot=tooltip-provider]) shares its delay and opens neighbours
// instantly within `timeout` ms of the last one closing. Emits `open-change` with { open }.
const providerState = new WeakMap()

export default class extends Controller {
  static targets = [ "trigger", "popup", "arrow", "template" ]
  static values = {
    click: Boolean, hover: Boolean, focus: Boolean, interactive: { type: Boolean, default: true },
    delay: { type: Number, default: 300 }, closeDelay: { type: Number, default: 0 }, track: String, closeOnClick: Boolean,
    open: Boolean
  }

  connect() {
    // A card inside running text is rendered in a <template> (its blocks would end the paragraph)
    this.templateTargets.forEach(template => template.replaceWith(template.content.cloneNode(true)))
    this.onOutside = event => { if (!this.element.contains(event.target)) this.close() }
    this.onKey = event => {
      if (event.key !== "Escape" || !this.isOpen) return
      event.preventDefault()
      this.close({ focusTrigger: this.clickValue })
    }
    this.onReflow = () => this.position()
    if (this.openValue) requestAnimationFrame(() => this.open())
  }

  disconnect() {
    this.clearTimers()
    this.close({ instant: true })
  }

  // Trigger events

  toggle(event) {
    if (this.clickValue) {
      this.isOpen && !this.openedByHover ? this.close({ focusTrigger: true }) : this.open({ focusContent: event.detail === 0 || !this.hover })
      this.openedByHover = false
    } else if (this.closeOnClickValue && this.isOpen) {
      this.close()
    }
  }

  pointerEnter(event) {
    if (!this.hover || event.pointerType === "touch") return
    clearTimeout(this.closeTimer)
    if (this.isOpen || event.currentTarget !== this.triggerTarget) return
    const delay = this.instant ? 0 : this.delay
    this.openTimer = setTimeout(() => { this.openedByHover = true; this.open({ instant: delay === 0 && this.instant }) }, delay)
  }

  pointerLeave(event) {
    if (!this.hover || event.pointerType === "touch") return
    clearTimeout(this.openTimer)
    const into = event.relatedTarget
    if (into && (this.triggerTarget.contains(into) || (this.interactiveValue && this.popupTarget.contains(into)))) return
    this.closeTimer = setTimeout(() => this.close(), this.closeDelay)
  }

  pointerMove(event) {
    if (!this.trackValue || !this.isOpen) return
    this.pointer = { x: event.clientX, y: event.clientY }
    this.position()
  }

  focusIn(event) {
    if (!this.focusValue || !event.target.matches(":focus-visible")) return
    clearTimeout(this.closeTimer)
    this.open({ instant: true })
  }

  focusOut(event) {
    if (!this.isOpen) return
    const into = event.relatedTarget
    if (into && this.element.contains(into)) return
    if (this.focusValue || this.hover) this.close()
  }

  // Open / close

  open({ focusContent = false, instant = false } = {}) {
    const popup = this.popupTarget
    clearTimeout(popup.hideTimer)
    popup.removeAttribute("data-ending-style")
    if (this.triggerTarget.hasAttribute("aria-haspopup")) this.triggerTarget.setAttribute("aria-expanded", "true")
    this.triggerTarget.setAttribute("data-popup-open", "")

    if (!popup.matches(":popover-open")) {
      popup.showPopover()
      popup.toggleAttribute("data-instant", instant)
      popup.setAttribute("data-starting-style", "")
      requestAnimationFrame(() => requestAnimationFrame(() => popup.removeAttribute("data-starting-style")))
      document.addEventListener("pointerdown", this.onOutside, true)
      document.addEventListener("keydown", this.onKey)
      window.addEventListener("resize", this.onReflow)
      window.addEventListener("scroll", this.onReflow, true)
      this.dispatch("open-change", { detail: { open: true } })
    }
    this.markOpen()
    this.position()
    if (focusContent && this.interactiveValue) {
      const target = popup.querySelector("[autofocus]") || popup.querySelector("a[href], button:not([disabled]), input:not([disabled]), textarea, select, [tabindex]:not([tabindex='-1'])")
      ;(target || popup).focus({ preventScroll: true })
    }
  }

  close({ focusTrigger = false, instant = false } = {}) {
    const popup = this.popupTarget
    if (!popup.matches(":popover-open") || popup.hasAttribute("data-ending-style")) return

    this.clearTimers()
    if (this.triggerTarget.hasAttribute("aria-haspopup")) this.triggerTarget.setAttribute("aria-expanded", "false")
    this.triggerTarget.removeAttribute("data-popup-open")
    document.removeEventListener("pointerdown", this.onOutside, true)
    document.removeEventListener("keydown", this.onKey)
    window.removeEventListener("resize", this.onReflow)
    window.removeEventListener("scroll", this.onReflow, true)
    this.markClosed()

    const hide = () => { popup.removeAttribute("data-ending-style"); popup.hidePopover() }
    if (instant || window.matchMedia("(prefers-reduced-motion: reduce)").matches) hide()
    else {
      popup.setAttribute("data-ending-style", "")
      popup.hideTimer = setTimeout(hide, 120)
    }
    if (focusTrigger) this.triggerTarget.focus({ preventScroll: true })
    this.dispatch("open-change", { detail: { open: false } })
  }

  position() {
    if (!this.popupTarget.matches(":popover-open")) return
    const popup = this.popupTarget
    popup.dataset.preferredSide ||= popup.dataset.side || "bottom"
    const anchor = this.trackValue && this.pointer ? this.trackedRect : this.triggerTarget
    placeFloating(popup, anchor, {
      side: popup.dataset.preferredSide, align: popup.dataset.align || "center",
      sideOffset: Number(popup.dataset.sideOffset || 6), alignOffset: Number(popup.dataset.alignOffset || 0),
      arrow: this.hasArrowTarget ? this.arrowTarget : null
    })
  }

  // Tooltip provider: a shared delay and instant neighbours

  get provider() {
    return this.element.closest("[data-slot=tooltip-provider]")
  }

  get hover() {
    return this.hoverValue || this.triggerTarget.dataset.hover === "true"
  }

  // The trigger's own delay, else the tooltip provider's, else the default
  get delay() {
    return Number(this.triggerTarget.dataset.delay ?? this.provider?.dataset.delay ?? this.delayValue)
  }

  get closeDelay() {
    return Number(this.triggerTarget.dataset.closeDelay ?? this.provider?.dataset.closeDelay ?? this.closeDelayValue)
  }

  // Another tooltip of the provider is open, or closed within its timeout
  get instant() {
    const provider = this.provider
    if (!provider) return false
    const state = providerState.get(provider) || {}
    return (state.open && state.open !== this) || Date.now() - (state.closedAt || 0) < Number(provider.dataset.timeout || 400)
  }

  markOpen() {
    if (this.provider) providerState.set(this.provider, { ...providerState.get(this.provider), open: this })
  }

  markClosed() {
    if (!this.provider) return
    const state = providerState.get(this.provider) || {}
    providerState.set(this.provider, { open: state.open === this ? null : state.open, closedAt: Date.now() })
  }

  get trackedRect() {
    const rect = this.triggerTarget.getBoundingClientRect()
    const x = this.trackValue === "y" ? rect.left + rect.width / 2 : this.pointer.x
    const y = this.trackValue === "x" ? (this.popupTarget.dataset.preferredSide === "bottom" ? rect.bottom : rect.top) : this.pointer.y
    return { left: x, right: x, top: y, bottom: y }
  }

  get isOpen() {
    return this.popupTarget.matches(":popover-open") && !this.popupTarget.hasAttribute("data-ending-style")
  }

  clearTimers() {
    clearTimeout(this.openTimer)
    clearTimeout(this.closeTimer)
  }
}
