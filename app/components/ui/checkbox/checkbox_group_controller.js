import { Controller } from "@hotwired/stimulus"

// UI::CheckboxGroup: keeps an optional "select all" parent in sync with the items (checked,
// indeterminate or clear) and toggles every enabled item from it. Emits
// `ui--checkbox-group:change` with { value } - the checked items' values.
export default class extends Controller {
  static targets = [ "item", "parent" ]

  connect() {
    this.sync()
  }

  update({ target }) {
    if (this.parentTargets.includes(target)) return

    this.sync()
    this.dispatch("change", { detail: { value: this.value } })
  }

  toggleAll({ target }) {
    this.enabledItems.forEach(item => item.checked = target.checked)
    this.sync()
    this.dispatch("change", { detail: { value: this.value } })
  }

  sync() {
    const checked = this.itemTargets.filter(item => item.checked).length
    this.parentTargets.forEach(parent => {
      parent.checked = checked > 0 && checked === this.itemTargets.length
      parent.indeterminate = checked > 0 && checked < this.itemTargets.length
    })
  }

  get enabledItems() {
    return this.itemTargets.filter(item => !item.disabled)
  }

  get value() {
    return this.itemTargets.filter(item => item.checked).map(item => item.value)
  }
}
