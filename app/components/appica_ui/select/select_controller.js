import { Controller } from "@hotwired/stimulus"

// AppicaUI::Select: opens the listbox in the top layer (popover) over or below the trigger, moves a
// highlight with the keyboard (aria-activedescendant - focus stays on the trigger), typeahead,
// selects (toggling when multiple), clears, and mirrors the value into the trigger and the form
// inputs. Emits `appica-ui--select:change` with { value } and `appica-ui--select:open-change` with { open }.
export default class extends Controller {
  static targets = [ "trigger", "value", "start", "clear", "content", "list", "item", "input", "hidden" ]
  static values = { multiple: Boolean, align: { type: Boolean, default: true }, name: String, readOnly: Boolean }

  connect() {
    this.typed = ""
    this.onOutside = event => { if (!this.element.contains(event.target) && !this.contentTarget.contains(event.target)) this.close() }
    this.onReflow = () => this.position()
    this.render()
  }

  disconnect() {
    this.close({ immediate: true })
  }

  toggle() {
    this.open ? this.close() : this.show()
  }

  show() {
    if (this.open || this.disabled) return

    const content = this.contentTarget
    content.showPopover?.()
    content.removeAttribute("data-ending-style")
    content.setAttribute("data-starting-style", "")
    this.triggerTarget.setAttribute("aria-expanded", "true")
    this.triggerTarget.setAttribute("data-popup-open", "")
    this.highlight(this.selectedItems[0] || this.enabledItems[0], { scroll: true })
    this.position()
    requestAnimationFrame(() => content.removeAttribute("data-starting-style"))

    document.addEventListener("pointerdown", this.onOutside, true)
    window.addEventListener("resize", this.onReflow)
    window.addEventListener("scroll", this.onReflow, true)
    this.dispatch("open-change", { detail: { open: true } })
  }

  close({ immediate = false } = {}) {
    if (!this.open) return

    const content = this.contentTarget
    this.triggerTarget.setAttribute("aria-expanded", "false")
    this.triggerTarget.removeAttribute("data-popup-open")
    this.triggerTarget.removeAttribute("aria-activedescendant")
    document.removeEventListener("pointerdown", this.onOutside, true)
    window.removeEventListener("resize", this.onReflow)
    window.removeEventListener("scroll", this.onReflow, true)

    const hide = () => { content.removeAttribute("data-ending-style"); content.hidePopover?.() }
    const duration = parseFloat(getComputedStyle(content).transitionDuration) || 0
    if (immediate || !duration) return hide()

    content.setAttribute("data-ending-style", "")
    content.addEventListener("transitionend", hide, { once: true })
    setTimeout(hide, duration * 1000 + 50)
    this.dispatch("open-change", { detail: { open: false } })
  }

  key(event) {
    if (event.target !== this.triggerTarget) return
    const items = this.enabledItems

    switch (event.key) {
      case "ArrowDown":
      case "ArrowUp": {
        event.preventDefault()
        if (!this.open) return this.show()
        const index = items.indexOf(this.highlighted)
        const next = event.key === "ArrowDown" ? Math.min(items.length - 1, index + 1) : Math.max(0, index - 1)
        return this.highlight(items[next], { scroll: true })
      }
      case "Home":
      case "End":
        if (!this.open) return
        event.preventDefault()
        return this.highlight(event.key === "Home" ? items[0] : items[items.length - 1], { scroll: true })
      case "Enter":
      case " ":
        event.preventDefault()
        if (!this.open) return this.show()
        if (event.key === " " && this.typed) return this.typeahead(event.key)
        if (this.highlighted) this.choose(this.highlighted)
        return
      case "Escape":
        if (this.open) { event.preventDefault(); this.close() }
        return
      case "Tab":
        return this.close()
      case "Delete":
      case "Backspace":
        if (this.clearTargets.length && this.values.length) { event.preventDefault(); this.setValues([]) }
        return
      default:
        if (event.key.length === 1 && !event.metaKey && !event.ctrlKey && !event.altKey) this.typeahead(event.key)
    }
  }

  typeahead(char) {
    clearTimeout(this.typeTimer)
    this.typed += char.toLowerCase()
    this.typeTimer = setTimeout(() => this.typed = "", 600)

    const items = this.enabledItems
    const start = this.typed.length === 1 ? items.indexOf(this.highlighted) + 1 : items.indexOf(this.highlighted)
    const ordered = [ ...items.slice(Math.max(0, start)), ...items.slice(0, Math.max(0, start)) ]
    const match = ordered.find(item => this.labelOf(item).toLowerCase().startsWith(this.typed))
    if (!match) return

    if (this.open) this.highlight(match, { scroll: true })
    else if (!this.multipleValue) this.setValues([ match.dataset.value ])
  }

  hover({ currentTarget }) {
    if (!currentTarget.hasAttribute("data-disabled")) this.highlight(currentTarget)
  }

  pick({ currentTarget }) {
    if (!currentTarget.hasAttribute("data-disabled")) this.choose(currentTarget)
  }

  choose(item) {
    if (this.readOnlyValue) return this.close()

    const value = item.dataset.value
    if (this.multipleValue) {
      const values = this.values.includes(value) ? this.values.filter(v => v !== value) : [ ...this.values, value ]
      this.setValues(values)
    } else {
      this.setValues([ value ])
      this.close()
      this.triggerTarget.focus()
    }
  }

  clear(event) {
    event.preventDefault()
    event.stopPropagation()
    if (this.readOnlyValue) return
    this.setValues([])
    this.triggerTarget.focus()
  }

  // Pressing in the popup keeps the focus (and the keyboard) on the trigger
  keepFocus(event) {
    event.preventDefault()
  }

  focusTrigger() {
    this.triggerTarget.focus()
  }

  focusOut(event) {
    if (this.open && !this.element.contains(event.relatedTarget) && !this.contentTarget.contains(event.relatedTarget)) this.close()
  }

  setValues(values) {
    const before = this.values.join("\u0000")
    this.values = values
    this.render()
    if (before === values.join("\u0000")) return

    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
    this.dispatch("change", { detail: { value: this.multipleValue ? values : (values[0] ?? null) } })
  }

  // The trigger text, placeholder state, clear button, start slot, items and form inputs
  render() {
    const values = this.values
    this.itemTargets.forEach(item => {
      const selected = values.includes(item.dataset.value)
      item.setAttribute("aria-selected", selected)
      item.toggleAttribute("data-selected", selected)
      item.querySelector("[data-slot=select-item-indicator]")?.toggleAttribute("data-selected", selected)
    })

    this.triggerTarget.toggleAttribute("data-placeholder", values.length === 0)
    this.clearTargets.forEach(clear => clear.hidden = values.length === 0)
    if (this.hasValueTarget) {
      const value = this.valueTarget
      value.toggleAttribute("data-placeholder", values.length === 0)
      value.textContent = values.length === 0 ? (value.dataset.placeholderText || "")
        : values.length === 1 ? this.labelFor(values[0])
        : (value.dataset.summary || "%{count}").replace("%{count}", values.length)
    }
    if (this.hasStartTarget && this.startTarget.childElementCount === 0 || this.startMirrored) {
      const source = this.selectedItems[0]?.querySelector("[data-icon=start]")
      this.startTarget.replaceChildren(...(source && values.length === 1 ? [ this.mirror(source) ] : []))
      this.startMirrored = true
    }

    this.inputTarget.value = values.join(",")
    if (this.multipleValue && this.nameValue) {
      this.hiddenTargets.forEach(input => input.remove())
      values.forEach(value => {
        const input = Object.assign(document.createElement("input"), { type: "hidden", name: this.nameValue.endsWith("[]") ? this.nameValue : `${this.nameValue}[]`, value, disabled: this.inputTarget.disabled })
        input.setAttribute("data-appica-ui--select-target", "hidden")
        this.inputTarget.before(input)
      })
    }
  }

  mirror(source) {
    const copy = source.cloneNode(true)
    copy.removeAttribute("data-icon")
    return copy
  }

  highlight(item, { scroll = false } = {}) {
    this.itemTargets.forEach(other => other.toggleAttribute("data-highlighted", other === item))
    this.highlighted = item
    if (item) {
      this.triggerTarget.setAttribute("aria-activedescendant", item.id)
      if (scroll) item.scrollIntoView({ block: "nearest" })
    }
  }

  // Over the trigger with the selected item on top of it, or below / above the trigger
  position() {
    if (!this.open) return

    const content = this.contentTarget
    const trigger = this.triggerTarget.getBoundingClientRect()
    const offset = Number(content.dataset.sideOffset || 6)
    const margin = 8
    const rtl = getComputedStyle(this.element).direction === "rtl"
    const selected = this.selectedItems[0]
    const align = this.alignValue && selected && !this.multipleValue

    content.style.width = `${trigger.width + (align ? 16 : 0)}px`
    content.style.setProperty("--anchor-width", `${trigger.width}px`)
    const left = align ? trigger.left - 8 : trigger.left
    content.style.left = `${rtl ? trigger.right - content.offsetWidth + (align ? 8 : 0) : left}px`

    if (align) {
      this.listTarget.style.setProperty("--available-height", `${window.innerHeight - margin * 2}px`)
      const itemTop = selected.offsetTop - this.listTarget.scrollTop
      let top = trigger.top + trigger.height / 2 - (itemTop + selected.offsetHeight / 2)
      top = Math.max(margin, Math.min(top, window.innerHeight - content.offsetHeight - margin))
      content.style.top = `${top}px`
      content.style.transformOrigin = "center"
    } else {
      const below = window.innerHeight - trigger.bottom - offset - margin
      const above = trigger.top - offset - margin
      const side = content.dataset.side === "top" ? (above > 160 || above > below ? "top" : "bottom") : (below > 160 || below >= above ? "bottom" : "top")
      this.listTarget.style.setProperty("--available-height", `${Math.max(120, side === "bottom" ? below : above)}px`)
      content.style.top = side === "bottom" ? `${trigger.bottom + offset}px` : `${trigger.top - offset - content.offsetHeight}px`
      content.style.transformOrigin = side === "bottom" ? "top" : "bottom"
      content.dataset.currentSide = side
    }
  }

  labelFor(value) {
    const item = this.itemTargets.find(item => item.dataset.value === value)
    return item ? this.labelOf(item) : value
  }

  labelOf(item) {
    return item.dataset.label || item.querySelector("[data-slot=select-item-text]")?.textContent.trim() || item.dataset.value
  }

  get values() {
    if (this._values === undefined) this._values = this.itemTargets.filter(item => item.hasAttribute("data-selected")).map(item => item.dataset.value)
    return this._values
  }

  set values(values) {
    this._values = values
  }

  get selectedItems() {
    return this.itemTargets.filter(item => this.values.includes(item.dataset.value))
  }

  get enabledItems() {
    return this.itemTargets.filter(item => !item.hasAttribute("data-disabled"))
  }

  get open() {
    return this.triggerTarget.getAttribute("aria-expanded") === "true"
  }

  get disabled() {
    return this.triggerTarget.disabled
  }
}
