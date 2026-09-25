import { Controller } from "@hotwired/stimulus"

// The clear (✕) button of UI::Input / UI::Textarea: empties the field, tells listeners it
// changed (an `input` event, as if the user had typed) and puts the focus back.
export default class extends Controller {
  static targets = [ "control" ]

  clear() {
    const control = this.controlTarget
    control.value = ""
    control.dispatchEvent(new Event("input", { bubbles: true }))
    control.focus()
    this.dispatch("clear")
  }
}
