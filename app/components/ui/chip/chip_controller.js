import { Controller } from "@hotwired/stimulus"

// A dismissible UI::Chip (on its wrapper): plays the exit transition, then removes the chip and
// emits `ui--chip:dismiss` - cancel that event to keep it in the DOM.
export default class extends Controller {
  dismiss() {
    if (this.dismissing) return

    const event = this.dispatch("dismiss", { cancelable: true })
    if (event.defaultPrevented) return

    this.dismissing = true
    this.element.setAttribute("data-ending-style", "")
    const done = () => this.element.remove()
    const duration = parseFloat(getComputedStyle(this.element).transitionDuration) || 0
    duration ? this.element.addEventListener("transitionend", done, { once: true }) : done()
    setTimeout(done, duration * 1000 + 100)
  }
}
