import { Controller } from "@hotwired/stimulus"

// Keeps SparklineChart, SparklineValue and SparklineLabel on the nearest pointer
// reading. Emits `ui--sparkline:active-change` with { point }, or { point: null }
// when the pointer leaves / touch ends.
export default class extends Controller {
  static targets = [
    "value", "label", "customValue", "customLabel", "guide", "dot", "column",
    "tooltip", "tooltipLabel", "tooltipValue", "customTooltip"
  ]

  static values = { data: Array, labels: Array, formattedValues: Array }

  activate(event) {
    const chart = event.currentTarget
    const rect = chart.getBoundingClientRect()
    if (rect.width === 0 || this.dataValue.length === 0) return

    let position = Math.min(1, Math.max(0, (event.clientX - rect.left) / rect.width))
    if (getComputedStyle(this.element).direction === "rtl") position = 1 - position

    const index = chart.dataset.variant === "column"
      ? Math.min(this.dataValue.length - 1, Math.floor(position * this.dataValue.length))
      : Math.round(position * (this.dataValue.length - 1))

    this.show(index, chart)
  }

  clear() {
    this.reset()
  }

  release(event) {
    if (event.pointerType !== "mouse") this.reset()
  }

  show(index, chart) {
    const point = {
      index,
      value: this.dataValue[index],
      label: this.hasLabelsValue ? this.labelsValue[index] : undefined
    }
    const marker = JSON.parse(chart.dataset.points)[index]
    const left = (getComputedStyle(this.element).direction === "rtl" ? 1 - marker.left_frac : marker.left_frac) * 100
    const top = marker.top_frac * 100

    this.updateReading(index)

    if (chart.dataset.variant === "column") {
      this.columnTargets.forEach((column, columnIndex) => {
        column.toggleAttribute("data-active", chart.dataset.indicator === "true" && columnIndex === index)
      })
    } else if (chart.dataset.indicator === "true") {
      this.guideTargets.forEach(guide => { guide.hidden = false; guide.style.left = `${left}%` })
      this.dotTargets.forEach(dot => { dot.hidden = false; dot.style.left = `${left}%`; dot.style.top = `${top}%` })
    }

    this.tooltipTargets.forEach(tooltip => {
      tooltip.hidden = false
      tooltip.style.left = `${left}%`
      tooltip.style.top = `${top}%`
    })
    this.tooltipLabelTargets.forEach(label => { label.hidden = point.label === undefined; label.textContent = point.label || "" })
    this.tooltipValueTargets.forEach(value => { value.textContent = this.formattedValuesValue[index] || "" })
    this.showIndexed(this.customTooltipTargets, index)

    this.dispatch("active-change", { detail: { point } })
  }

  reset() {
    const index = this.dataValue.length - 1
    this.updateReading(index)
    this.guideTargets.forEach(guide => { guide.hidden = true })
    this.dotTargets.forEach(dot => { dot.hidden = true })
    this.columnTargets.forEach(column => column.removeAttribute("data-active"))
    this.tooltipTargets.forEach(tooltip => { tooltip.hidden = true })
    this.customTooltipTargets.forEach(content => { content.hidden = true })
    this.dispatch("active-change", { detail: { point: null } })
  }

  updateReading(index) {
    this.valueTargets.forEach(value => { value.textContent = this.formattedValuesValue[index] || "" })
    this.labelTargets.forEach(label => { label.textContent = this.hasLabelsValue ? (this.labelsValue[index] || "") : "" })
    this.showIndexed(this.customValueTargets, index)
    this.showIndexed(this.customLabelTargets, index)
  }

  showIndexed(targets, index) {
    targets.forEach(target => { target.hidden = Number(target.dataset.index) !== index })
  }
}
