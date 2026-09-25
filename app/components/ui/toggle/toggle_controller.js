import { Controller } from "@hotwired/stimulus"

// A standalone UI::Toggle: flips aria-pressed / data-pressed on click and emits
// `ui--toggle:change` with { pressed }.
export default class extends Controller {
  toggle() {
    if (this.element.disabled) return

    const pressed = this.element.getAttribute("aria-pressed") !== "true"
    this.element.setAttribute("aria-pressed", pressed)
    this.element.toggleAttribute("data-pressed", pressed)
    this.dispatch("change", { detail: { pressed } })
  }
}
