import { Controller } from "@hotwired/stimulus"

// Live updates for UI::Meter (Base UI's Meter in Appica's React version). The server renders
// the initial state; change the value and the fill, color, text and ARIA follow:
//
//   meter.setAttribute("data-ui--meter-value-value", 3)
export default class extends Controller {
  static targets = [ "indicator", "value" ]
  static values = {
    value: Number, min: { type: Number, default: 0 }, max: { type: Number, default: 100 },
    low: Number, high: Number, optimum: Number,
    format: Object, locale: String, statusClasses: Object
  }

  // Stimulus runs change callbacks once before connect() (with the default as the previous
  // value); the server already rendered that state, so only react once connected
  connect() {
    this.connected = true
  }

  disconnect() {
    this.connected = false
  }

  valueValueChanged(value) {
    if (!this.connected) return

    const clamped = Math.min(Math.max(value, this.minValue), this.maxValue)
    const percentage = ((clamped - this.minValue) / (this.maxValue - this.minValue)) * 100 || 0
    const formatted = this.format(clamped, percentage)
    const status = this.status(value)

    this.element.setAttribute("aria-valuenow", clamped)
    this.element.setAttribute("aria-valuetext", formatted)
    if (status) this.element.dataset.status = status

    this.indicatorTargets.forEach(indicator => {
      indicator.style.width = `${percentage}%`
      indicator.classList.remove(...Object.values(this.statusClassesValue).flatMap(classes => classes.split(" ")))
      indicator.classList.add(...(this.statusClassesValue[status || "default"] || "").split(" ").filter(Boolean))
    })

    this.valueTargets.forEach(target => {
      const labels = target.dataset.labels && JSON.parse(target.dataset.labels)
      target.textContent = labels ? labels[Math.min(Math.max(Math.round(value), 0), labels.length - 1)] : formatted
    })
  }

  format(value, percentage) {
    const locale = this.localeValue || undefined
    if (this.hasFormatValue) return new Intl.NumberFormat(locale, this.formatValue).format(value)

    return new Intl.NumberFormat(locale, { style: "percent" }).format(percentage / 100)
  }

  // Same zones as the server: the one `optimum` falls in is green, next amber, far red
  status(value) {
    if (!this.hasLowValue && !this.hasHighValue && !this.hasOptimumValue) return null

    const low = this.hasLowValue ? this.lowValue : this.minValue
    const high = this.hasHighValue ? this.highValue : this.maxValue
    const zone = number => number < low ? 0 : number > high ? 2 : 1
    const optimum = this.hasOptimumValue ? this.optimumValue : (this.minValue + this.maxValue) / 2

    return [ "optimum", "suboptimum", "invalid" ][Math.abs(zone(value) - zone(optimum))]
  }
}
