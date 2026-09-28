import { Controller } from "@hotwired/stimulus"

// AppicaUI::Slider: drags the nearest thumb from anywhere on the track, handles the keyboard on the
// hidden range inputs, and keeps the fill, thumb positions, tooltips and inputs in sync.
// Emits `appica-ui--slider:change` ({ value }) while moving and `appica-ui--slider:commit` on release.
export default class extends Controller {
  static targets = [ "control", "indicator", "thumb", "tooltip", "input" ]
  static values = { min: Number, max: { type: Number, default: 100 }, step: { type: Number, default: 1 }, largeStep: { type: Number, default: 10 },
    minStepsBetween: Number, format: Object, locale: String }

  start(event) {
    if (event.button !== 0 || this.element.hasAttribute("data-disabled")) return

    event.preventDefault()
    const value = this.valueAt(event)
    this.active = this.nearest(value)
    this.inputTargets[this.active].focus()
    this.setAt(this.active, value)

    const thumb = this.thumbTargets[this.active]
    thumb.setAttribute("data-dragging", "")
    const move = event => this.setAt(this.active, this.valueAt(event))
    const end = () => {
      thumb.removeAttribute("data-dragging")
      window.removeEventListener("pointermove", move)
      window.removeEventListener("pointerup", end)
      this.commit()
    }
    window.addEventListener("pointermove", move)
    window.addEventListener("pointerup", end)
  }

  key(event) {
    const index = this.inputTargets.indexOf(event.target)
    const current = this.values[index]
    const vertical = this.orientation === "vertical"
    const rtl = !vertical && getComputedStyle(this.element).direction === "rtl"
    const step = event.shiftKey ? this.largeStepValue : this.stepValue
    const moves = {
      ArrowRight: rtl ? -step : step, ArrowLeft: rtl ? step : -step, ArrowUp: step, ArrowDown: -step,
      PageUp: this.largeStepValue, PageDown: -this.largeStepValue
    }
    let value

    if (event.key in moves) value = current + moves[event.key]
    else if (event.key === "Home") value = this.minValue
    else if (event.key === "End") value = this.maxValue
    else return

    event.preventDefault()
    this.setAt(index, value)
    this.commit()
  }

  focus({ target }) {
    this.active = this.inputTargets.indexOf(target)
  }

  // Snaps, clamps between the neighbours and updates everything
  setAt(index, raw) {
    const gap = this.minStepsBetweenValue * this.stepValue
    const low = index > 0 ? this.values[index - 1] + gap : this.minValue
    const high = index < this.inputTargets.length - 1 ? this.values[index + 1] - gap : this.maxValue
    const snapped = Math.round((raw - this.minValue) / this.stepValue) * this.stepValue + this.minValue
    const value = Number(Math.min(high, Math.max(low, snapped)).toFixed(10))
    if (value === this.values[index]) return

    this.inputTargets[index].value = value
    this.render()
    this.dispatch("change", { detail: { value: this.value } })
  }

  commit() {
    this.inputTargets.forEach(input => input.dispatchEvent(new Event("change", { bubbles: true })))
    this.dispatch("commit", { detail: { value: this.value } })
  }

  render() {
    const values = this.values
    const percents = values.map(value => this.percent(value))
    const [ from, to ] = values.length > 1 ? [ percents[0], percents[percents.length - 1] ] : [ 0, percents[0] ]
    const vertical = this.orientation === "vertical"

    this.indicatorTarget.style[vertical ? "bottom" : "insetInlineStart"] = `${from}%`
    this.indicatorTarget.style[vertical ? "height" : "width"] = `${to - from}%`
    this.thumbTargets.forEach((thumb, index) => thumb.style[vertical ? "bottom" : "insetInlineStart"] = `${percents[index]}%`)
    this.inputTargets.forEach((input, index) => {
      const text = this.format(values[index])
      if (this.hasFormatValue) input.setAttribute("aria-valuetext", text)
      const tooltip = this.thumbTargets[index].querySelector("[data-appica-ui--slider-target=tooltip]")
      if (tooltip) tooltip.textContent = text
    })
  }

  valueAt(event) {
    const rect = this.controlTarget.getBoundingClientRect()
    let ratio
    if (this.orientation === "vertical") {
      ratio = (rect.bottom - event.clientY) / rect.height
    } else {
      ratio = (event.clientX - rect.left) / rect.width
      if (getComputedStyle(this.element).direction === "rtl") ratio = 1 - ratio
    }
    return this.minValue + Math.min(1, Math.max(0, ratio)) * (this.maxValue - this.minValue)
  }

  nearest(value) {
    const values = this.values
    let best = 0
    values.forEach((current, index) => {
      if (Math.abs(current - value) < Math.abs(values[best] - value) || (current === values[best] && value > current)) best = index
    })
    return best
  }

  percent(value) {
    return this.maxValue > this.minValue ? (value - this.minValue) / (this.maxValue - this.minValue) * 100 : 0
  }

  format(value) {
    if (!this.hasFormatValue) return String(value)
    return new Intl.NumberFormat(this.localeValue || undefined, this.formatValue).format(value)
  }

  get orientation() {
    return this.element.dataset.orientation
  }

  get values() {
    return this.inputTargets.map(input => Number(input.value))
  }

  get value() {
    return this.inputTargets.length > 1 ? this.values : this.values[0]
  }
}
