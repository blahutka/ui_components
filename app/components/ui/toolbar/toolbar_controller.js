import { Controller } from "@hotwired/stimulus"

// UI::Toolbar: a roving tabindex over its items - arrows along the orientation (following the
// reading direction), Home / End, wrapping with `loop`. Inputs keep ←/→ until the caret is at
// an edge. Disabled items (aria-disabled) stay reachable but don't act.
export default class extends Controller {
  static targets = [ "item" ]
  static values = { loop: { type: Boolean, default: true } }

  connect() {
    this.rove(this.itemTargets[0])
    this.onClick = event => {
      const item = this.itemTargets.find(item => item.contains(event.target))
      if (item?.getAttribute("aria-disabled") === "true") { event.preventDefault(); event.stopImmediatePropagation() }
    }
    this.element.addEventListener("click", this.onClick, true)
  }

  disconnect() {
    this.element.removeEventListener("click", this.onClick, true)
  }

  itemTargetConnected() {
    if (!this.itemTargets.some(item => item.tabIndex === 0)) this.rove(this.itemTargets[0])
  }

  track(event) {
    const item = this.itemTargets.find(item => item === event.target || item.contains(event.target))
    if (item) this.rove(item)
  }

  navigate(event) {
    // A popup inside (a Select) keeps its own keys while open
    if (event.target.closest("[aria-expanded=true]") || event.defaultPrevented) return

    const items = this.itemTargets
    const current = items.find(item => item === event.target || item.contains(event.target))
    if (!current) return

    const vertical = this.element.dataset.orientation === "vertical"
    const rtl = getComputedStyle(this.element).direction === "rtl"
    const keys = vertical ? { ArrowUp: -1, ArrowDown: 1 } : { ArrowLeft: rtl ? 1 : -1, ArrowRight: rtl ? -1 : 1 }
    let index = items.indexOf(current)

    if (event.key in keys) {
      if (!vertical && this.caretInside(event.target, keys[event.key] * (rtl ? -1 : 1))) return
      index += keys[event.key]
      index = this.loopValue ? (index + items.length) % items.length : Math.max(0, Math.min(items.length - 1, index))
    } else if (event.key === "Home" || event.key === "End") {
      if (event.target.tagName === "INPUT") return
      index = event.key === "Home" ? 0 : items.length - 1
    } else {
      return
    }

    event.preventDefault()
    this.rove(items[index])
    this.focusable(items[index]).focus()
  }

  rove(current) {
    this.itemTargets.forEach(item => this.focusable(item).tabIndex = item === current ? 0 : -1)
  }

  // An item can wrap its control (ToolbarInput around an Input)
  focusable(item) {
    return item.matches("input, button, a, select, textarea") ? item : (item.querySelector("input, button, a, select, textarea") || item)
  }

  // ←/→ inside a text input move the caret until it reaches the edge
  caretInside(target, direction) {
    if (target.tagName !== "INPUT" || target.selectionStart === null) return false
    return direction < 0 ? target.selectionStart > 0 : target.selectionEnd < target.value.length
  }
}
