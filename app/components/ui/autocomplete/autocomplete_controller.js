import { Controller } from "@hotwired/stimulus"

// Behaviour for UI::Autocomplete (the Base UI Autocomplete part of Appica's React version):
// filtering, open/close, keyboard navigation, ARIA combobox state and the state
// attributes the Appica classes style against (data-popup-open, data-highlighted, data-empty…).
//
// Emits `ui--autocomplete:change` with { value } whenever the value changes
// (typing, selection, clear) — the counterpart of React's onValueChange.
export default class extends Controller {
  static targets = [ "anchor", "input", "content", "list", "item", "group", "clear", "toggle", "selectedIcon" ]
  static values = { grid: Boolean }

  connect() {
    this.highlighted = null
    this.outsideClick = this.outsideClick.bind(this)
    document.addEventListener("pointerdown", this.outsideClick)

    this.itemTargets.forEach((item, index) => item.id ||= `${this.element.id}-option-${index}`)
    this.syncSelection()
  }

  disconnect() {
    document.removeEventListener("pointerdown", this.outsideClick)
  }

  // Actions

  focus() {
    if (!this.isOpen) this.open()
  }

  filter() {
    this.applyFilter()
    this.open()
    this.highlight(null)
    this.syncSelection()
    this.dispatchChange()
  }

  navigate(event) {
    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.isOpen ? this.move(this.rowStep) : this.open()
        break
      case "ArrowUp":
        event.preventDefault()
        this.isOpen ? this.move(-this.rowStep) : this.open()
        break
      case "ArrowRight":
        if (this.isOpen && this.gridValue && this.highlighted) { event.preventDefault(); this.move(this.isRtl ? -1 : 1) }
        break
      case "ArrowLeft":
        if (this.isOpen && this.gridValue && this.highlighted) { event.preventDefault(); this.move(this.isRtl ? 1 : -1) }
        break
      case "Home":
      case "End":
        if (this.isOpen && this.highlighted) {
          event.preventDefault()
          const items = this.visibleItems
          this.highlight(event.key === "Home" ? items[0] : items[items.length - 1])
        }
        break
      case "Enter":
        if (this.isOpen && this.highlighted) {
          event.preventDefault()
          this.choose(this.highlighted)
        }
        break
      case "Escape":
        if (this.isOpen) {
          event.preventDefault()
          this.close()
        }
        break
      case "Tab":
        this.close()
        break
    }
  }

  select(event) {
    const item = event.currentTarget
    if (!this.isDisabled(item)) this.choose(item)
  }

  hover(event) {
    const item = event.currentTarget
    if (!this.isDisabled(item) && item !== this.highlighted) this.highlight(item, { scroll: false })
  }

  clear() {
    this.inputTarget.value = ""
    this.inputTarget.focus()
    this.filter()
  }

  toggle() {
    this.inputTarget.focus()
    this.isOpen ? this.close() : this.open()
  }

  // Clicking inside the popup must not blur the input
  keepFocus(event) {
    event.preventDefault()
  }

  outsideClick(event) {
    if (this.isOpen && !this.element.contains(event.target)) this.close()
  }

  // Open / close

  get isOpen() {
    return this.hasContentTarget && !this.contentTarget.hidden
  }

  open() {
    if (this.isOpen || !this.hasContentTarget || this.inputTarget.disabled) return

    this.applyFilter()
    this.contentTarget.hidden = false
    this.placeContent()
    this.setPopupState(true)

    // Commit the starting styles, then drop them so the popup transitions in
    this.contentTarget.setAttribute("data-starting-style", "")
    getComputedStyle(this.contentTarget).opacity
    this.contentTarget.removeAttribute("data-starting-style")
  }

  close() {
    if (!this.isOpen) return

    this.highlight(null)
    this.setPopupState(false)

    const content = this.contentTarget
    content.setAttribute("data-ending-style", "")
    const finish = () => {
      content.removeAttribute("data-ending-style")
      if (!content.hasAttribute("data-open")) content.hidden = true
    }
    if (this.prefersReducedMotion) finish()
    else setTimeout(finish, 100)
  }

  setPopupState(open) {
    const elements = [ this.anchorTarget, this.inputTarget, ...this.toggleTargets, this.contentTarget ]
    elements.forEach(element => element.toggleAttribute(element === this.contentTarget ? "data-open" : "data-popup-open", open))
    this.inputTarget.setAttribute("aria-expanded", open)
    this.toggleTargets.forEach(toggle => toggle.setAttribute("aria-expanded", open))
  }

  // Flip above the input when there is not enough room below (Floating UI's flip, simplified)
  placeContent() {
    const content = this.contentTarget
    const preferred = content.dataset.preferredSide ||= content.dataset.side || "bottom"
    content.dataset.side = preferred

    const anchor = this.anchorTarget.getBoundingClientRect()
    const height = content.getBoundingClientRect().height
    const below = window.innerHeight - anchor.bottom
    const above = anchor.top

    if (preferred === "bottom" && below < height && above > below) content.dataset.side = "top"
    if (preferred === "top" && above < height && below > above) content.dataset.side = "bottom"

    this.anchorTarget.dataset.popupSide = content.dataset.side
  }

  // Filtering

  applyFilter() {
    const query = this.normalize(this.inputTarget.value)

    this.itemTargets.forEach(item => {
      item.hidden = query.length > 0 && !this.normalize(item.dataset.value).includes(query)
    })

    this.groupTargets.forEach(group => {
      group.hidden = !group.querySelector("[data-slot='autocomplete-item']:not([hidden])")
    })

    const empty = this.visibleItems.length === 0
    if (this.hasContentTarget) this.contentTarget.toggleAttribute("data-empty", empty)
    if (this.hasListTarget) this.listTarget.hidden = empty
  }

  normalize(text) {
    return (text || "").toLocaleLowerCase().normalize("NFD").replace(/\p{Diacritic}/gu, "").trim()
  }

  get visibleItems() {
    return this.itemTargets.filter(item => !item.hidden && !this.isDisabled(item))
  }

  // Highlight & selection

  get rowStep() {
    return this.gridValue && this.hasListTarget ? Number(this.listTarget.dataset.cols || 1) : 1
  }

  move(step) {
    const items = this.visibleItems
    if (items.length === 0) return

    const index = items.indexOf(this.highlighted)
    let next

    if (index === -1) {
      next = step > 0 ? items[0] : items[items.length - 1]
    } else if (index + step >= items.length || index + step < 0) {
      next = null // loop focus back to the input, like Base UI's loopFocus
    } else {
      next = items[index + step]
    }

    this.highlight(next)
  }

  highlight(item, { scroll = true } = {}) {
    this.highlighted?.removeAttribute("data-highlighted")
    this.highlighted = item

    if (item) {
      item.setAttribute("data-highlighted", "")
      this.inputTarget.setAttribute("aria-activedescendant", item.id)
      if (scroll) item.scrollIntoView({ block: "nearest" })
    } else {
      this.inputTarget.removeAttribute("aria-activedescendant")
    }
  }

  choose(item) {
    this.inputTarget.value = item.dataset.value
    this.close()
    this.syncSelection()
    this.dispatchChange()
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }

  syncSelection() {
    const value = this.inputTarget.value
    const selected = this.itemTargets.find(item => item.dataset.value === value)

    this.itemTargets.forEach(item => item.setAttribute("aria-selected", item === selected))
    this.clearTargets.forEach(clear => { clear.hidden = value.length === 0 })

    this.selectedIconTargets.forEach(slot => {
      const icon = selected?.querySelector("[data-icon='start']")
      slot.replaceChildren()
      if (icon) {
        const clone = icon.cloneNode(true)
        clone.removeAttribute("data-icon")
        clone.setAttribute("aria-hidden", "true")
        slot.append(clone)
      }
    })
  }

  dispatchChange() {
    this.dispatch("change", { detail: { value: this.inputTarget.value } })
  }

  // Helpers

  isDisabled(item) {
    return item.hasAttribute("data-disabled")
  }

  get isRtl() {
    return getComputedStyle(this.element).direction === "rtl"
  }

  get prefersReducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }
}
