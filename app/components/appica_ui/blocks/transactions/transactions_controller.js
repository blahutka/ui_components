import { Controller } from "@hotwired/stimulus"

// Behaviour for AppicaUI::Blocks::Transactions: the All / Income / Spending tabs hide the rows of the other
// kind (each row's data-kind), mark the first visible row (so it drops its divider) and show the
// empty message when nothing matches.
export default class extends Controller {
  static targets = [ "row", "empty" ]

  filter({ detail: { value } }) {
    let first = null
    this.rowTargets.forEach(row => {
      const visible = value === "all" || row.dataset.kind === value
      row.hidden = !visible
      row.removeAttribute("data-first")
      if (visible && !first) first = row
    })
    first?.setAttribute("data-first", "")
    if (this.hasEmptyTarget) this.emptyTarget.hidden = first !== null
  }
}
