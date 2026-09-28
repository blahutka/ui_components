import { Controller } from "@hotwired/stimulus"

// AppicaUI::ChipGroup: `clearAll` dismisses every dismissible chip inside.
export default class extends Controller {
  clearAll() {
    this.element.querySelectorAll("[data-slot=chip][data-dismissible]").forEach(chip => chip.click())
  }
}
