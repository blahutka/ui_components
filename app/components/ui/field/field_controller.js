import { Controller } from "@hotwired/stimulus"

// Validation for UI::Field with the browser's own constraints (required, type, pattern,
// minlength…). `mode` decides when: "submit" (the form's submit, which is stopped while
// invalid), "blur" or "change"; once invalid it re-checks on every change until fixed.
// `messages` ({ valueMissing: "…" }) replace the browser's text per failure. Toggles
// data-invalid on the field, its control and the control's wrapper, and aria-invalid.
export default class extends Controller {
  static targets = [ "control", "error", "message" ]
  static values = { mode: { type: String, default: "submit" }, messages: Object }

  static failures = [ "valueMissing", "typeMismatch", "patternMismatch", "tooShort", "tooLong", "rangeUnderflow", "rangeOverflow", "stepMismatch", "badInput", "customError" ]

  connect() {
    this.onInput = () => { if (this.modeValue === "change" || this.element.hasAttribute("data-invalid")) this.validate() }
    this.onBlur = () => { if (this.modeValue === "blur") this.validate() }
    this.onSubmit = event => { if (!this.validate()) { event.preventDefault(); this.controlTarget?.focus() } }

    this.element.addEventListener("input", this.onInput)
    this.element.addEventListener("change", this.onInput)
    this.element.addEventListener("focusout", this.onBlur)
    this.form = this.element.closest("form")
    this.form?.addEventListener("submit", this.onSubmit)
  }

  disconnect() {
    this.element.removeEventListener("input", this.onInput)
    this.element.removeEventListener("change", this.onInput)
    this.element.removeEventListener("focusout", this.onBlur)
    this.form?.removeEventListener("submit", this.onSubmit)
  }

  // Checks the control; returns whether it's valid
  validate() {
    if (!this.hasControlTarget) return true

    const control = this.controlTarget
    control.setCustomValidity("")
    const validity = control.validity
    const failure = this.constructor.failures.find(key => validity[key])
    const valid = !failure

    this.setInvalid(!valid)
    this.errorTargets.forEach(error => {
      const match = error.dataset.match
      error.hidden = valid || (match ? match !== failure : false)
    })
    this.describeErrors()
    if (this.hasMessageTarget) this.messageTarget.textContent = valid ? "" : (this.messagesValue[failure] || control.validationMessage)

    this.dispatch(valid ? "valid" : "invalid", { detail: { failure } })
    return valid
  }

  // aria-describedby lists the description and whichever errors are showing
  describeErrors() {
    const errorIds = this.errorTargets.map(error => error.id)
    const ids = (this.controlTarget.getAttribute("aria-describedby") || "").split(" ").filter(id => id && !errorIds.includes(id))
    ids.push(...this.errorTargets.filter(error => !error.hidden).map(error => error.id))
    ids.length ? this.controlTarget.setAttribute("aria-describedby", ids.join(" ")) : this.controlTarget.removeAttribute("aria-describedby")
  }

  setInvalid(invalid) {
    const control = this.controlTarget
    const wrapper = control.closest("[data-slot$=-wrapper]")
    ;[ this.element, control, wrapper ].filter(Boolean).forEach(element => element.toggleAttribute("data-invalid", invalid))
    control.toggleAttribute("aria-invalid", invalid)
    if (invalid) control.setAttribute("aria-invalid", "true")
  }
}
