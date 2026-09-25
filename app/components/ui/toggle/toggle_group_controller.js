import { Controller } from "@hotwired/stimulus"

// UI::ToggleGroup: presses toggles (releasing the others unless `multiple`), keeps one tab stop
// with arrow-key focus along the orientation, mirrors the pressed values into hidden inputs when
// named, and emits `ui--toggle-group:change` with { value }.
export default class extends Controller {
  static targets = [ "item", "input" ]
  static values = { multiple: Boolean, loop: { type: Boolean, default: true }, name: String }

  connect() {
    this.rove(this.itemTargets.find(item => this.isPressed(item) && !item.disabled) || this.enabledItems[0])
  }

  press(event) {
    const item = this.itemTargets.find(item => item.contains(event.target))
    if (!item || item.disabled) return

    const pressed = !this.isPressed(item)
    if (pressed && !this.multipleValue) this.itemTargets.forEach(other => this.setPressed(other, false))
    this.setPressed(item, pressed)
    this.rove(item)
    this.syncInputs()
    this.dispatch("change", { detail: { value: this.value } })
  }

  navigate(event) {
    const vertical = this.element.dataset.orientation === "vertical"
    const rtl = getComputedStyle(this.element).direction === "rtl"
    const keys = vertical ? { ArrowUp: -1, ArrowDown: 1 } : { ArrowLeft: rtl ? 1 : -1, ArrowRight: rtl ? -1 : 1 }
    const items = this.enabledItems
    const index = items.indexOf(document.activeElement)
    let next

    if (event.key in keys) next = index + keys[event.key]
    else if (event.key === "Home") next = 0
    else if (event.key === "End") next = items.length - 1
    else return

    event.preventDefault()
    if (this.loopValue) next = (next + items.length) % items.length
    const item = items[Math.max(0, Math.min(items.length - 1, next))]
    this.rove(item)
    item?.focus()
  }

  rove(current) {
    this.itemTargets.forEach(item => item.tabIndex = item === current ? 0 : -1)
  }

  setPressed(item, pressed) {
    item.setAttribute("aria-pressed", pressed)
    item.toggleAttribute("data-pressed", pressed)
  }

  syncInputs() {
    if (!this.nameValue) return

    this.inputTargets.forEach(input => input.remove())
    this.value.forEach(value => {
      const input = Object.assign(document.createElement("input"), { type: "hidden", name: `${this.nameValue}[]`, value })
      input.dataset.uiToggleGroupTarget = "input"
      this.element.append(input)
    })
  }

  isPressed(item) {
    return item.getAttribute("aria-pressed") === "true"
  }

  get enabledItems() {
    return this.itemTargets.filter(item => !item.disabled)
  }

  get value() {
    return this.itemTargets.filter(item => this.isPressed(item)).map(item => item.value)
  }
}
