import { Controller } from "@hotwired/stimulus"

// Behaviour for Blocks::TeamMembers. The invite form validates the email and posts it (Turbo);
// the server appends a TeamMember to the list with a Turbo Stream. Whenever the list changes the
// seat count is recomputed and, once every seat is taken, the form disables. In demo mode (no
// `action:`) the invited row is added here.
//
// Emits `blocks--team-members:invite` with { email } (cancel it to handle the invite yourself).
export default class extends Controller {
  static targets = [ "list", "seats", "input", "send", "inviteButton", "memberTemplate" ]
  static values = { demo: Boolean, seats: Number, seatsLabel: String }

  connect() {
    this.observer = new MutationObserver(() => this.refresh())
    if (this.hasListTarget) this.observer.observe(this.listTarget, { childList: true })
  }

  disconnect() {
    this.observer?.disconnect()
  }

  focus() {
    if (this.hasInputTarget && !this.inputTarget.disabled) this.inputTarget.focus()
  }

  clearError() {
    this.inputTarget.setCustomValidity("")
    this.inputTarget.form.removeAttribute("data-invalid")
  }

  invite(event) {
    const input = this.inputTarget
    const email = input.value.trim()

    if (!input.checkValidity() || !email) {
      event.preventDefault()
      input.setCustomValidity(input.dataset.invalid)
      input.form.setAttribute("data-invalid", "")
      input.reportValidity()
      return
    }

    const invited = this.dispatch("invite", { detail: { email }, cancelable: true })
    if (invited.defaultPrevented) return event.preventDefault()

    if (this.demoValue) {
      event.preventDefault()
      this.addMember(email)
      input.value = ""
    } else {
      // Turbo reads the form data after this handler - clear the field once it has
      setTimeout(() => input.value = "")
    }
  }

  addMember(email) {
    const row = this.memberTemplateTarget.content.firstElementChild.cloneNode(true)
    const name = email.split("@")[0].replace(/[._-]+/g, " ").replace(/\b\w/g, letter => letter.toUpperCase())
    row.querySelector("[data-field=name]").textContent = name
    row.querySelector("[data-field=email]").textContent = email
    row.querySelector("[data-slot=avatar-fallback]").textContent = name.slice(0, 1)
    this.listTarget.append(row)
  }

  // The seat count and the form's state follow the rows in the list
  refresh() {
    const used = this.listTarget.querySelectorAll("[data-slot=team-member]").length
    const full = this.hasSeatsValue && used >= this.seatsValue

    if (this.hasSeatsTarget) {
      this.seatsTarget.textContent = this.seatsLabelValue.replace("%{used}", used).replace("%{seats}", this.seatsValue)
    }
    if (this.hasInputTarget) {
      this.inputTarget.disabled = full
      this.inputTarget.placeholder = full ? this.inputTarget.dataset.full : this.inputTarget.dataset.placeholder
    }
    ;[ ...this.sendTargets, ...this.inviteButtonTargets ].forEach(button => button.disabled = full)
  }
}
