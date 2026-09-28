import { Controller } from "@hotwired/stimulus"

// AppicaUI::CopyButton: copies `value` (or the `target` element's value / text) with the Clipboard
// API - falling back to a hidden textarea + execCommand where it's blocked (iframes, http) - then
// shows the copied state for `timeout` ms. Emits `appica-ui--copy-button:copy` / `:error`.
export default class extends Controller {
  static targets = [ "text", "status" ]
  static values = { value: String, target: String, timeout: { type: Number, default: 2000 }, label: String, copiedLabel: String }

  disconnect() {
    clearTimeout(this.timer)
  }

  async copy() {
    const text = this.text
    try {
      await this.write(text)
    } catch (error) {
      return this.dispatch("error", { detail: { error } })
    }

    this.restingText ??= this.hasTextTarget ? this.textTarget.textContent : null
    this.element.setAttribute("data-copied", "")
    this.element.setAttribute("aria-label", this.copiedLabelValue)
    this.statusTarget.textContent = this.copiedLabelValue
    if (this.hasTextTarget && this.restingText) this.textTarget.textContent = this.copiedLabelValue
    this.dispatch("copy", { detail: { value: text } })

    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.reset(), this.timeoutValue)
  }

  reset() {
    this.element.removeAttribute("data-copied")
    this.element.setAttribute("aria-label", this.labelValue)
    this.statusTarget.textContent = ""
    if (this.hasTextTarget && this.restingText) this.textTarget.textContent = this.restingText
  }

  async write(text) {
    try {
      await navigator.clipboard.writeText(text)
    } catch {
      const area = Object.assign(document.createElement("textarea"), { value: text })
      area.setAttribute("readonly", "")
      area.style.cssText = "position:fixed;opacity:0;pointer-events:none"
      document.body.append(area)
      area.select()
      const copied = document.execCommand("copy")
      area.remove()
      if (!copied) throw new Error("Copy failed")
    }
  }

  get text() {
    if (!this.targetValue) return this.valueValue

    const element = document.querySelector(this.targetValue)
    return element ? ("value" in element && element.value !== undefined ? element.value : element.textContent.trim()) : ""
  }
}
