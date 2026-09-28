import { Controller } from "@hotwired/stimulus"

// AppicaUI::Dialog: opens the native <dialog> (showModal() for a modal - top layer, focus trap, inert
// page), plays the enter / exit transitions via data-starting-style / data-ending-style, closes
// on Escape (the `cancel` event), a click outside (when dismissible) or a close button, and steps
// a parent dialog back while a nested one is open. Emits `open-change` with { open }.
export default class extends Controller {
  static targets = [ "trigger", "dialog", "backdrop", "popup" ]
  static values = { open: Boolean, modal: { type: Boolean, default: true }, dismissible: { type: Boolean, default: true } }

  connect() {
    if (this.openValue) this.open()
  }

  disconnect() {
    if (this.hasDialogTarget && this.dialogTarget.open) this.dialogTarget.close()
    this.parentPopup?.removeAttribute("data-nested-dialog-open")
  }

  open() {
    const dialog = this.dialogTarget
    if (dialog.open && !dialog.hasAttribute("data-closing")) return

    clearTimeout(this.closeTimer)
    dialog.removeAttribute("data-closing")
    if (!dialog.open) this.modalValue ? dialog.showModal() : dialog.show()
    this.transition("starting")
    this.triggerTargets.forEach(trigger => trigger.setAttribute("aria-expanded", "true"))

    this.parentPopup = this.element.parentElement?.closest("[data-slot$=-popup]")
    this.parentPopup?.setAttribute("data-nested-dialog-open", "")
    this.dispatch("open-change", { detail: { open: true } })
  }

  close() {
    const dialog = this.dialogTarget
    if (!dialog.open || dialog.hasAttribute("data-closing")) return

    dialog.setAttribute("data-closing", "")
    this.transition("ending")
    this.triggerTargets.forEach(trigger => trigger.setAttribute("aria-expanded", "false"))
    this.parentPopup?.removeAttribute("data-nested-dialog-open")

    const finish = () => {
      dialog.removeAttribute("data-closing")
      this.clearTransition()
      dialog.close()
    }
    const duration = parseFloat(getComputedStyle(this.popupTarget).transitionDuration) || 0
    this.closeTimer = setTimeout(finish, duration ? 250 : 0)
    this.dispatch("open-change", { detail: { open: false } })
  }

  // Escape: the browser would close the <dialog> at once - animate it instead
  cancel(event) {
    event.preventDefault()
    this.close()
  }

  // Clicks on the viewport around the card or on the backdrop
  outside(event) {
    if (!this.dismissibleValue) return
    const outside = event.target === this.dialogTarget || this.backdropTargets.includes(event.target)
    if (outside) this.close()
  }

  transition(phase) {
    const elements = [ this.popupTarget, ...this.backdropTargets ]
    this.clearTransition()
    elements.forEach(element => element.setAttribute(`data-${phase}-style`, ""))
    if (phase === "starting") requestAnimationFrame(() => requestAnimationFrame(() => this.clearTransition()))
  }

  clearTransition() {
    [ this.popupTarget, ...this.backdropTargets ].forEach(element => {
      element.removeAttribute("data-starting-style")
      element.removeAttribute("data-ending-style")
    })
  }
}
