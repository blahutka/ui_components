import { Controller } from "@hotwired/stimulus"

// Behaviour for Blocks::CommandMenu: typing filters the commands (hiding empty groups and showing
// the empty message), ↑ / ↓ move the highlight (data-active), ↵ runs the highlighted command and
// Escape clears the search. ⌘K / Ctrl+K (the `hotkey` value) focuses the search from anywhere.
//
// Emits `blocks--command-menu:select` with { value, label } when a command runs (cancel it to
// keep a link from being followed).
export default class extends Controller {
  static targets = [ "input", "item", "group", "empty" ]
  static values = { hotkey: String }

  connect() {
    this.highlight(this.visibleItems[0])
  }

  // Actions

  filter() {
    const query = this.normalize(this.inputTarget.value)

    this.itemTargets.forEach(item => {
      item.closest("li").hidden = query.length > 0 && !this.normalize(this.labelOf(item)).includes(query)
    })
    this.groupTargets.forEach(group => {
      group.hidden = !group.querySelector("li:not([hidden])")
    })
    this.emptyTarget.hidden = this.visibleItems.length > 0
    this.highlight(this.visibleItems[0])
  }

  navigate(event) {
    const items = this.visibleItems
    const index = items.indexOf(this.active)

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.highlight(items[(index + 1) % items.length])
        break
      case "ArrowUp":
        event.preventDefault()
        this.highlight(items[(index - 1 + items.length) % items.length])
        break
      case "Enter":
        if (this.active) {
          event.preventDefault()
          this.active.click()
        }
        break
      case "Escape":
        if (this.inputTarget.value) {
          event.preventDefault()
          this.inputTarget.value = ""
          this.filter()
        }
        break
    }
  }

  hover({ currentTarget }) {
    this.highlight(currentTarget, { scroll: false })
  }

  choose(event) {
    const item = event.currentTarget
    const selected = this.dispatch("select", { detail: { value: item.dataset.value || this.labelOf(item), label: this.labelOf(item) } })
    if (selected.defaultPrevented) event.preventDefault()
  }

  hotkeyPressed(event) {
    if (!this.hotkeyValue || event.key.toLowerCase() !== this.hotkeyValue || !(event.metaKey || event.ctrlKey)) return

    event.preventDefault()
    this.inputTarget.focus()
    this.inputTarget.select()
  }

  // Highlight

  highlight(item, { scroll = true } = {}) {
    this.itemTargets.forEach(other => other.toggleAttribute("data-active", other === item))
    this.active = item
    if (item && scroll) item.scrollIntoView({ block: "nearest" })
  }

  get visibleItems() {
    return this.itemTargets.filter(item => !item.closest("li").hidden)
  }

  labelOf(item) {
    return item.querySelector("[data-slot=command-item-label]")?.textContent.trim() || ""
  }

  normalize(text) {
    return (text || "").toLocaleLowerCase().normalize("NFD").replace(/\p{Diacritic}/gu, "").trim()
  }
}
