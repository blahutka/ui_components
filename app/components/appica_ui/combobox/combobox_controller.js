import AutocompleteController from "appica_ui/autocomplete/autocomplete_controller"

// AppicaUI::Combobox: the Autocomplete behaviour plus a selected value kept apart from the typed
// query - the input reverts to the selection's label on close, a `multiple` combobox renders
// chips, a ComboboxTrigger opens a popup with the search inside, and `creatable` offers the
// query as a new entry. Mirrors the value into the form inputs.
// Emits `appica-ui--combobox:change` ({ value }) and `appica-ui--combobox:create` ({ value }).
export default class extends AutocompleteController {
  static targets = [ ...AutocompleteController.targets, "trigger", "valueText", "chips", "chipTemplate", "hidden", "validity" ]
  static values = { ...AutocompleteController.values, multiple: Boolean, name: String, values: Array, createLabel: String }

  connect() {
    this.values = this.valuesValue.map(String)
    super.connect()
    this.render()
  }

  // Typing filters but doesn't change the value
  filter() {
    this.applyFilter()
    this.open()
    this.highlight(this.creatableItem || null)
  }

  focus() {
    if (!this.hasTriggerTarget) super.focus()
  }

  open() {
    super.open()
    if (this.hasTriggerTarget && this.isOpen) {
      this.triggerTarget.setAttribute("aria-expanded", "true")
      requestAnimationFrame(() => this.inputTarget.focus())
    }
  }

  close() {
    const wasOpen = this.isOpen
    super.close()
    if (!wasOpen) return

    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", "false")
      this.inputTarget.value = ""
    } else if (!this.multipleValue) {
      this.inputTarget.value = this.values[0] ? this.labelFor(this.values[0]) : ""
    }
    this.removeCreatable()
  }

  toggle() {
    if (this.hasTriggerTarget && this.triggerTarget.disabled) return
    if (this.isOpen) {
      this.close()
      if (this.hasTriggerTarget) this.triggerTarget.focus()
    } else {
      this.open()
      if (!this.hasTriggerTarget) this.inputTarget.focus()
    }
  }

  triggerKey(event) {
    if ([ "ArrowDown", "ArrowUp", "Enter", " " ].includes(event.key)) {
      event.preventDefault()
      this.open()
    }
  }

  navigate(event) {
    if (event.key === "Backspace" && this.multipleValue && this.inputTarget.value === "" && this.values.length) {
      return this.setValues(this.values.slice(0, -1))
    }
    if (event.key === "Escape" && this.isOpen && this.hasTriggerTarget) {
      event.preventDefault()
      this.close()
      return this.triggerTarget.focus()
    }
    super.navigate(event)
  }

  choose(item) {
    const value = item.dataset.value
    if (item.dataset.creatable !== undefined) {
      this.addItem(value)
      this.dispatch("create", { detail: { value } })
    }

    if (this.multipleValue) {
      this.setValues(this.values.includes(value) ? this.values.filter(v => v !== value) : [ ...this.values, value ])
      this.inputTarget.value = ""
      this.applyFilter()
      this.inputTarget.focus()
    } else {
      this.setValues([ value ])
      this.close()
      if (this.hasTriggerTarget) this.triggerTarget.focus()
    }
  }

  clear() {
    this.inputTarget.value = ""
    this.setValues([])
    this.applyFilter()
    this.inputTarget.focus()
  }

  remove(event) {
    event.stopPropagation()
    const value = event.currentTarget.closest("[data-slot=combobox-chip]").dataset.value
    this.setValues(this.values.filter(v => v !== value))
    this.inputTarget.focus()
  }

  // The hidden validity input takes the Field's focus; pass it on
  focusField() {
    (this.hasTriggerTarget ? this.triggerTarget : this.inputTarget).focus()
  }

  // Shows everything while the input still shows the selection; offers "Create …" when allowed
  applyFilter() {
    const query = this.inputTarget.value
    const showingSelection = !this.multipleValue && this.values[0] && query === this.labelFor(this.values[0])
    if (showingSelection) {
      this.inputTarget.value = ""
      super.applyFilter()
      this.inputTarget.value = query
    } else {
      super.applyFilter()
    }
    this.updateCreatable(showingSelection ? "" : query.trim())
  }

  updateCreatable(query) {
    this.removeCreatable()
    if (!this.hasCreateLabelValue || !query) return
    if (this.itemTargets.some(item => this.normalize(this.labelOf(item)) === this.normalize(query))) return

    const template = this.itemTargets[0]
    const item = document.createElement("div")
    item.className = template?.className || ""
    item.setAttribute("role", "option")
    item.setAttribute("aria-selected", "false")
    item.id = `${this.element.id}-create`
    Object.assign(item.dataset, { slot: "combobox-item", value: query, creatable: "", action: "click->appica-ui--combobox#select mousemove->appica-ui--combobox#hover" })
    item.textContent = this.createLabelValue.replace("%{query}", query)
    this.listTarget.append(item)
    this.listTarget.hidden = false
    this.contentTarget.removeAttribute("data-empty")
    this.creatableItem = item
  }

  removeCreatable() {
    this.creatableItem?.remove()
    this.creatableItem = null
  }

  get visibleItems() {
    return [ ...super.visibleItems, ...(this.creatableItem ? [ this.creatableItem ] : []) ]
  }

  // A created entry becomes a real option
  addItem(value) {
    const template = this.itemTargets[0]
    if (!template) return
    const item = template.cloneNode(true)
    item.dataset.value = value
    item.id = `${this.element.id}-option-${this.itemTargets.length}`
    item.removeAttribute("hidden")
    item.removeAttribute("data-highlighted")
    const text = item.querySelector("span")
    if (text) text.textContent = value
    this.listTarget.append(item)
  }

  setValues(values) {
    const changed = values.join("\u0000") !== this.values.join("\u0000")
    this.values = values
    this.render()
    if (!changed) return

    this.validityTarget.dispatchEvent(new Event("change", { bubbles: true }))
    this.dispatch("change", { detail: { value: this.multipleValue ? values : (values[0] ?? null) } })
  }

  // Reflect the values in the items, chips, trigger, clear button and form inputs
  render() {
    const values = this.values
    this.itemTargets.forEach(item => {
      const selected = values.includes(item.dataset.value)
      item.setAttribute("aria-selected", selected)
      item.toggleAttribute("data-selected", selected)
    })
    this.clearTargets.forEach(clear => clear.hidden = values.length === 0)

    if (!this.multipleValue && !this.hasTriggerTarget && document.activeElement !== this.inputTarget) {
      this.inputTarget.value = values[0] ? this.labelFor(values[0]) : ""
    }
    if (this.hasValueTextTarget) {
      this.valueTextTarget.textContent = values[0] ? this.labelFor(values[0]) : (this.valueTextTarget.dataset.placeholderText || "")
      this.triggerTarget.toggleAttribute("data-placeholder", !values[0])
    }
    if (this.hasChipsTarget) {
      this.chipsTarget.querySelectorAll("[data-slot=combobox-chip]").forEach(chip => chip.remove())
      values.forEach(value => {
        const chip = this.chipTemplateTarget.content.firstElementChild.cloneNode(true)
        const label = this.labelFor(value)
        chip.dataset.value = value
        chip.setAttribute("aria-label", label)
        chip.querySelector("[data-slot=combobox-chip-label]").textContent = label
        this.inputTarget.before(chip)
      })
    }
    this.syncSelectedIcon()

    this.validityTarget.value = values.join(",")
    if (this.multipleValue && this.nameValue) {
      this.hiddenTargets.forEach(input => input.remove())
      values.forEach(value => {
        const input = Object.assign(document.createElement("input"), { type: "hidden", name: this.nameValue.endsWith("[]") ? this.nameValue : `${this.nameValue}[]`, value, disabled: this.validityTarget.disabled })
        input.setAttribute("data-appica-ui--combobox-target", "hidden")
        this.validityTarget.before(input)
      })
    }
  }

  // The Autocomplete keeps the selection in the input; here it's the value
  syncSelection() {}

  syncSelectedIcon() {
    const selected = this.itemTargets.find(item => item.dataset.value === this.values[0])
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

  textOf(item) {
    return this.labelOf(item)
  }

  labelFor(value) {
    const item = this.itemTargets.find(item => item.dataset.value === value)
    return item ? this.labelOf(item) : value
  }

  labelOf(item) {
    return item.dataset.label || item.querySelector("span")?.textContent.trim() || item.dataset.value
  }

  outsideClick(event) {
    if (this.isOpen && !this.element.contains(event.target)) this.close()
  }
}
