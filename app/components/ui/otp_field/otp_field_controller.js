import { Controller } from "@hotwired/stimulus"

// UI::OTPField: one character per slot - filters by the pattern, advances, handles Backspace,
// arrows and pasted / autofilled codes, mirrors the joined value into the hidden input and
// emits `ui--otp-field:change` / `:complete` with { value } (submitting the form if asked).
export default class extends Controller {
  static targets = [ "input", "hidden" ]
  static values = { pattern: { type: String, default: "\\d" }, autoSubmit: Boolean }

  type(event) {
    const input = event.target
    const index = this.inputTargets.indexOf(input)
    if (index === -1) return

    // Autofill or a fast typist can put several characters into one slot
    const accepted = [ ...input.value ].filter(char => this.accepts(char))
    if (accepted.length > 1) return this.fill(index, accepted)

    input.value = accepted[0] || ""
    this.update()
    if (input.value) this.focusAt(index + 1)
  }

  key(event) {
    const input = event.target
    const index = this.inputTargets.indexOf(input)
    if (index === -1) return
    const rtl = getComputedStyle(this.element).direction === "rtl"

    if (event.key === "Backspace" && !input.value) {
      event.preventDefault()
      const previous = this.inputTargets[index - 1]
      if (previous && !previous.readOnly) { previous.value = ""; this.update() }
      this.focusAt(index - 1)
    } else if (event.key === "ArrowLeft" || event.key === "ArrowRight") {
      event.preventDefault()
      this.focusAt(index + ((event.key === "ArrowRight") !== rtl ? 1 : -1))
    } else if (event.key === "Home" || event.key === "End") {
      event.preventDefault()
      this.focusAt(event.key === "Home" ? 0 : this.inputTargets.length - 1)
    } else if (event.key.length === 1 && !event.metaKey && !event.ctrlKey && input.value && this.accepts(event.key) && !input.readOnly) {
      // Typing over a filled slot replaces it
      event.preventDefault()
      input.value = event.key
      this.update()
      this.focusAt(index + 1)
    }
  }

  paste(event) {
    const index = this.inputTargets.indexOf(event.target)
    if (index === -1 || event.target.readOnly) return

    event.preventDefault()
    this.fill(index, [ ...(event.clipboardData?.getData("text") || "") ].filter(char => this.accepts(char)))
  }

  select(event) {
    if (this.inputTargets.includes(event.target)) requestAnimationFrame(() => event.target.select())
  }

  focusFirst() {
    (this.inputTargets.find(input => !input.value) || this.inputTargets[0])?.focus()
  }

  fill(start, chars) {
    chars.slice(0, this.inputTargets.length - start).forEach((char, offset) => this.inputTargets[start + offset].value = char)
    this.update()
    this.focusAt(Math.min(start + chars.length, this.inputTargets.length - 1))
  }

  update() {
    this.inputTargets.forEach(input => input.toggleAttribute("data-filled", input.value !== ""))
    const value = this.value
    this.hiddenTarget.value = value
    this.hiddenTarget.dispatchEvent(new Event("change", { bubbles: true }))
    this.dispatch("change", { detail: { value } })

    if (value.length === this.inputTargets.length) {
      this.dispatch("complete", { detail: { value } })
      if (this.autoSubmitValue) this.element.closest("form")?.requestSubmit()
    }
  }

  focusAt(index) {
    this.inputTargets[Math.max(0, Math.min(this.inputTargets.length - 1, index))]?.focus()
  }

  accepts(char) {
    return new RegExp(`^${this.patternValue}$`).test(char)
  }

  get value() {
    return this.inputTargets.map(input => input.value).join("")
  }
}
