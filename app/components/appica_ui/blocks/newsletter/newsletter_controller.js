import { Controller } from "@hotwired/stimulus"

// Behaviour for AppicaUI::Blocks::Newsletter. The browser validates the email (the Field shows the message);
// a filled honeypot drops the submission silently. After a successful Turbo submit - or at once in
// demo mode (no `action:`) - the note becomes a thank-you, a status message is announced and the
// field clears.
//
// Emits `appica-ui--blocks--newsletter:subscribed` with { email }.
export default class extends Controller {
  static targets = [ "form", "honeypot", "email", "status", "note" ]
  static values = { demo: Boolean, thanks: String }

  submit(event) {
    if (this.hasHoneypotTarget && this.honeypotTarget.value) {
      event.preventDefault()
      return
    }
    if (this.demoValue) {
      event.preventDefault()
      // After the Field has validated this submit - clearing the email first would fail it
      setTimeout(() => this.succeed())
    }
  }

  submitted({ detail: { success } }) {
    if (success) this.succeed()
  }

  succeed() {
    const email = this.emailTarget.value
    this.statusTarget.textContent = this.thanksValue
    this.noteTarget.textContent = this.thanksValue
    this.noteTarget.setAttribute("data-success", "")
    this.emailTarget.value = ""
    this.dispatch("subscribed", { detail: { email } })
  }
}
