import { Controller } from "@hotwired/stimulus"

// Behaviour for AppicaUI::Rating: the pointer previews the rating a click would set (snapped to
// `step`) and lifts the item under it; a click commits it (or clears it with `clearable`);
// arrow keys step by `step`, Home/End jump to the ends, Space/Enter select the focused item.
// ←/→ swap under RTL. Emits `appica-ui--rating:change` with { value } and `appica-ui--rating:hover-change`
// with { value } (null when the pointer leaves).
export default class extends Controller {
  static targets = [ "item", "input" ]
  static values = { value: Number, step: { type: Number, default: 1 }, count: { type: Number, default: 5 }, clearable: Boolean, hoverable: { type: Boolean, default: true } }

  connect() {
    this.connected = true
  }

  disconnect() {
    this.connected = false
  }

  preview(event) {
    const item = event.target.closest("[data-slot=rating-item]")
    if (!this.hoverableValue || !item || item.disabled) return

    const value = this.valueAt(item, event)
    if (value === this.previewing) return

    this.previewing = value
    this.paint(value)
    this.itemTargets.forEach(other => other.toggleAttribute("data-hovered", other === item))
    this.dispatch("hover-change", { detail: { value } })
  }

  reset() {
    if (this.previewing === undefined) return

    this.previewing = undefined
    this.paint(this.valueValue)
    this.itemTargets.forEach(item => item.removeAttribute("data-hovered"))
    this.dispatch("hover-change", { detail: { value: null } })
  }

  select(event) {
    const item = event.currentTarget
    // A pointer click commits what it previewed; a keyboard "click" the whole item
    const picked = event.detail > 0 && this.previewing !== undefined ? this.previewing : Number(item.dataset.index)
    this.commit(this.clearableValue && picked === this.valueValue ? 0 : picked)
  }

  navigate(event) {
    const rtl = getComputedStyle(this.element).direction === "rtl"
    const forward = { ArrowRight: !rtl, ArrowLeft: rtl, ArrowDown: true, ArrowUp: false }[event.key]

    let value
    if (forward !== undefined) value = this.valueValue + (forward ? this.stepValue : -this.stepValue)
    else if (event.key === "Home") value = this.stepValue
    else if (event.key === "End") value = this.countValue
    else return

    event.preventDefault()
    value = this.clamp(value)
    this.commit(value)
    // The change callback runs asynchronously; focus the item for the new value right away
    this.itemTargets.find(item => Number(item.dataset.index) === Math.ceil(value))?.focus()
  }

  commit(value) {
    this.valueValue = this.round(value)
  }

  valueValueChanged(value) {
    if (!this.connected) return

    this.paint(value)
    const checked = value > 0 ? Math.ceil(value) : null
    this.itemTargets.forEach(item => {
      const index = Number(item.dataset.index)
      item.setAttribute("aria-checked", String(index === checked))
      item.toggleAttribute("data-checked", index === checked)
      item.tabIndex = index === (checked ?? 1) ? 0 : -1
    })
    if (this.hasInputTarget) this.inputTarget.value = value
    this.dispatch("change", { detail: { value } })
  }

  // The rating under the pointer: the item's index plus how far into it, rounded up to `step`
  valueAt(item, event) {
    const rect = item.getBoundingClientRect()
    const vertical = this.element.dataset.orientation === "vertical"
    const rtl = getComputedStyle(this.element).direction === "rtl"
    const offset = vertical ? event.clientY - rect.top : (rtl ? rect.right - event.clientX : event.clientX - rect.left)
    const fraction = Math.min(Math.max(offset / (vertical ? rect.height : rect.width), 0), 1)
    const raw = Number(item.dataset.index) - 1 + fraction

    return this.clamp(Math.ceil(this.round(raw / this.stepValue)) * this.stepValue)
  }

  paint(value) {
    this.itemTargets.forEach(item => {
      const fill = Math.min(Math.max(value - (Number(item.dataset.index) - 1), 0), 1)
      item.style.setProperty("--rating-fill", `${this.round(fill * 100)}%`)
    })
  }

  clamp(value) {
    return Math.min(Math.max(this.round(value), this.stepValue), this.countValue)
  }

  round(value) {
    return Math.round(value * 10000) / 10000
  }
}
