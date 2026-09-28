import { Controller } from "@hotwired/stimulus"

// A standalone AppicaUI::Toggle: flips aria-pressed / data-pressed on click, keeps its named hidden
// input (right before it) at the pressed / released value and emits `appica-ui--toggle:change` with { pressed }.
export default class extends Controller {
  toggle() {
    if (this.element.disabled) return

    const pressed = this.element.getAttribute("aria-pressed") !== "true"
    this.element.setAttribute("aria-pressed", pressed)
    this.element.toggleAttribute("data-pressed", pressed)
    this.syncInput(pressed)
    this.dispatch("change", { detail: { pressed } })
  }

  syncInput(pressed) {
    const input = this.element.previousElementSibling
    if (input?.dataset.slot !== "toggle-input") return

    const value = pressed ? input.dataset.checkedValue : input.dataset.uncheckedValue
    input.disabled = value === undefined
    input.value = value ?? ""
  }
}
