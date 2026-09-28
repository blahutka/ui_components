import { Controller } from "@hotwired/stimulus"

// AppicaUI::NumberField: parses what's typed, steps with the keys, the steppers (repeating while
// held) and optionally the wheel, clamps to min/max, formats with Intl and mirrors the plain
// number into the hidden input. Emits `appica-ui--number-field:change` with { value }.
export default class extends Controller {
  static targets = [ "input", "hidden", "increment", "decrement" ]
  static values = { min: Number, max: Number, step: { type: Number, default: 1 }, smallStep: { type: Number, default: 0.1 },
    largeStep: { type: Number, default: 10 }, format: Object, locale: String, invalidMessage: String }

  connect() {
    const now = this.inputTarget.getAttribute("aria-valuenow")
    this.value = now === null ? null : Number(now)
    // A re-rendered invalid entry ("abc") stays as typed until it's edited
    this.render({ keepText: now === null && this.inputTarget.value !== "" })
  }

  disconnect() {
    this.release()
  }

  // While typing only the hidden value follows; the display is re-formatted on commit
  type() {
    const value = this.parse(this.inputTarget.value)
    this.setHidden(value === null ? this.inputTarget.value : value)
    this.updateValidity(value)
  }

  commit() {
    const value = this.parse(this.inputTarget.value)
    this.updateValidity(value)
    // Invalid entries must survive a submit and server error re-render unchanged.
    if (this.inputTarget.validity.valid) this.set(value)
  }

  key(event) {
    const step = event.shiftKey ? this.largeStepValue : event.altKey ? this.smallStepValue : this.stepValue
    if (event.key === "ArrowUp") this.stepBy(step)
    else if (event.key === "ArrowDown") this.stepBy(-step)
    else if (event.key === "Home" && this.hasMinValue) this.set(this.minValue)
    else if (event.key === "End" && this.hasMaxValue) this.set(this.maxValue)
    else if (event.key === "Enter") return this.commit()
    else return
    event.preventDefault()
  }

  increment(event) {
    if (event.detail === 0) this.stepBy(this.stepValue) // keyboard "click"; pointer steps come from hold
  }

  decrement(event) {
    if (event.detail === 0) this.stepBy(-this.stepValue)
  }

  // Step once on press, then repeat until released
  hold(event) {
    if (event.button !== 0 || event.currentTarget.disabled || this.readOnly) return

    event.preventDefault()
    const direction = event.currentTarget === this.incrementTarget ? 1 : -1
    const step = (event.shiftKey ? this.largeStepValue : this.stepValue) * direction
    this.inputTarget.focus()
    this.stepBy(step)
    this.repeat = setTimeout(() => { this.interval = setInterval(() => this.stepBy(step), 60) }, 400)
  }

  release() {
    clearTimeout(this.repeat)
    clearInterval(this.interval)
  }

  wheel(event) {
    if (document.activeElement !== this.inputTarget) return

    event.preventDefault()
    this.stepBy(event.deltaY < 0 ? this.stepValue : -this.stepValue)
  }

  stepBy(amount) {
    if (this.inputTarget.disabled || this.readOnly) return

    const base = this.value ?? (this.hasMinValue ? this.minValue : 0)
    this.set(Number((base + amount).toFixed(10)))
  }

  set(value) {
    if (value !== null) {
      if (this.hasMinValue) value = Math.max(this.minValue, value)
      if (this.hasMaxValue) value = Math.min(this.maxValue, value)
    }
    const changed = value !== this.value
    this.value = value
    this.render()
    if (changed) {
      this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
      this.dispatch("change", { detail: { value } })
    }
  }

  render({ keepText = false } = {}) {
    const value = this.value
    if (!keepText) this.inputTarget.value = value === null ? "" : this.format(value)
    if (value === null) {
      this.inputTarget.removeAttribute("aria-valuenow")
      this.inputTarget.removeAttribute("aria-valuetext")
    } else {
      this.inputTarget.setAttribute("aria-valuenow", value)
      if (this.hasFormatValue) this.inputTarget.setAttribute("aria-valuetext", this.format(value))
    }
    if (!keepText) this.setHidden(value)
    this.updateValidity(value)
    if (this.hasIncrementTarget) this.incrementTarget.disabled = this.inputTarget.disabled || this.readOnly || (this.hasMaxValue && value !== null && value >= this.maxValue)
    if (this.hasDecrementTarget) this.decrementTarget.disabled = this.inputTarget.disabled || this.readOnly || (this.hasMinValue && value !== null && value <= this.minValue)
  }

  setHidden(value) {
    if (this.hasHiddenTarget) this.hiddenTarget.value = value === null ? "" : value
  }

  // The visible control is text so it can show formatted numbers and invalid raw input.
  // Let a native number input supply localized min/max/step validation messages.
  updateValidity(value) {
    const input = this.inputTarget
    const validityInput = document.createElement("input")
    validityInput.type = "number"
    for (const attribute of [ "min", "max", "step", "required" ]) {
      if (input.hasAttribute(attribute)) validityInput.setAttribute(attribute, input.getAttribute(attribute))
    }
    validityInput.value = value === null ? "" : String(value)
    input.setCustomValidity(value === null && input.value.trim() !== "" ? this.invalidMessageValue : validityInput.validationMessage)
  }

  format(value) {
    return new Intl.NumberFormat(this.localeValue || undefined, { maximumFractionDigits: 10, ...this.formatValue }).format(value)
  }

  // "1 234,5 Kč" → 1234.5; percent input is shown ×100
  parse(text) {
    const parts = new Intl.NumberFormat(this.localeValue || undefined).formatToParts(1234.5)
    const decimal = parts.find(part => part.type === "decimal")?.value || "."
    const group = parts.find(part => part.type === "group")?.value
    if (!this.hasFormatValue && [...text].some(character => !"0123456789+-".includes(character) && character !== decimal && character !== group && !/\s/.test(character))) return null
    const cleaned = text.replace(new RegExp(`[^0-9\\-${decimal === "." ? "\\." : decimal}]`, "g"), "").replace(decimal, ".")
    if (cleaned === "" || cleaned === "-" || isNaN(Number(cleaned))) return null

    const number = Number(cleaned)
    return this.formatValue.style === "percent" ? Number((number / 100).toFixed(10)) : number
  }

  get readOnly() {
    return this.inputTarget.readOnly
  }
}
