import { Controller } from "@hotwired/stimulus"

// Live updates for AppicaUI::Progress (Base UI's Progress in Appica's React version). The server
// renders the initial state; change the value and the bar or ring, the text, the ARIA and
// the data-progressing / data-complete state follow:
//
//   progress.setAttribute("data-appica-ui--progress-value-value", 42)
export default class extends Controller {
  static targets = [ "indicator", "ring", "value" ]
  static values = { value: Number, min: { type: Number, default: 0 }, max: { type: Number, default: 100 }, format: Object, locale: String }

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

    this.element.setAttribute("aria-valuenow", clamped)
    this.element.setAttribute("aria-valuetext", formatted)
    this.setState(value >= this.maxValue ? "complete" : "progressing")

    this.indicatorTargets.forEach(indicator => {
      indicator.style.cssText = `inset-inline-start: 0; height: inherit; width: ${percentage}%`
    })
    this.ringTargets.forEach(ring => {
      const circumference = parseFloat(ring.getAttribute("stroke-dasharray"))
      ring.setAttribute("stroke-dashoffset", circumference - (percentage / 100) * circumference)
    })
    this.valueTargets.forEach(target => target.textContent = formatted)
  }

  format(value, percentage) {
    const locale = this.localeValue || undefined
    if (this.hasFormatValue) return new Intl.NumberFormat(locale, this.formatValue).format(value)

    return new Intl.NumberFormat(locale, { style: "percent" }).format(percentage / 100)
  }

  setState(state) {
    const parts = [ this.element, ...this.element.querySelectorAll("[data-slot^=progress-]") ]
    parts.forEach(part => {
      if (part.dataset.slot === "progress-circular") return

      ;[ "indeterminate", "progressing", "complete" ].forEach(name => part.toggleAttribute(`data-${name}`, name === state))
    })
  }
}
