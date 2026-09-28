import { Controller } from "@hotwired/stimulus"

// A checkbox rendered as indeterminate (a DOM property, not an attribute) - the first click
// resolves it like any native checkbox.
export default class extends Controller {
  connect() {
    this.element.indeterminate = true
  }
}
