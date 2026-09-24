import { Controller } from "@hotwired/stimulus"

// Behaviour for UI::Menubar (Base UI's Menubar in Appica's React version):
//
// - triggers: click toggles a menu; once one is open, hovering a sibling switches to it;
//   arrow keys move along the bar (roving tabindex) and open menus
// - menus: arrow keys / Home / End move the highlight, Enter / Space select, Escape closes a
//   level, typeahead jumps to matching items, → / ← open and close submenus (mirrored in RTL)
// - submenus open on hover (after a short delay), click or the arrow key, flipping at the edge
// - checkbox and radio items keep their state in aria-checked / data-checked
//
// Events: `ui--menubar:select` { item, label }, `ui--menubar:checked-change` { item, checked },
// `ui--menubar:value-change` { group, value }, `ui--menubar:open-change` { menu, open }.
const ITEM = "[role=menuitem], [role=menuitemcheckbox], [role=menuitemradio]"
const HOVER_DELAY = 100

export default class extends Controller {
  static targets = [ "menu", "trigger", "content" ]
  static values = { loop: { type: Boolean, default: true } }

  connect() {
    this.openMenu = null
    this.typed = ""
    this.onPointerMove = this.pointerMove.bind(this)
    this.onClick = this.click.bind(this)
    this.element.addEventListener("pointermove", this.onPointerMove)
    this.element.addEventListener("click", this.onClick)
    this.setRoving(this.enabledTriggers[0])
  }

  disconnect() {
    this.element.removeEventListener("pointermove", this.onPointerMove)
    this.element.removeEventListener("click", this.onClick)
    clearTimeout(this.hoverTimer)
    clearTimeout(this.typeTimer)
  }

  // Trigger actions

  toggle(event) {
    const menu = this.menuFor(event.currentTarget)
    if (this.isDisabled(event.currentTarget)) return

    if (this.openMenu === menu) {
      this.closeAll({ focusTrigger: true })
    } else {
      this.open(menu)
    }
  }

  // Hovering a sibling trigger while a menu is open switches to its menu
  switch(event) {
    const menu = this.menuFor(event.currentTarget)
    if (this.openMenu && this.openMenu !== menu && !this.isDisabled(event.currentTarget)) {
      this.open(menu, { focus: "trigger" })
    }
  }

  dismiss(event) {
    if (this.openMenu && !this.element.contains(event.target)) this.closeAll()
  }

  // Keyboard

  navigate(event) {
    if (event.target.matches("[data-slot=menubar-trigger]")) {
      this.triggerKey(event, event.target)
    } else if (event.target.closest("[role=menu]")) {
      this.menuKey(event, event.target.closest("[role=menu]"))
    }
  }

  triggerKey(event, trigger) {
    const menu = this.menuFor(trigger)
    const [ nextKey, prevKey ] = this.barKeys
    const openKeys = this.vertical ? [ this.forwardKey, "Enter", " " ] : [ "ArrowDown", "Enter", " " ]

    if (event.key === nextKey || event.key === prevKey) {
      event.preventDefault()
      const sibling = this.siblingTrigger(trigger, event.key === nextKey ? 1 : -1)
      if (sibling) this.moveToTrigger(sibling)
    } else if (openKeys.includes(event.key)) {
      event.preventDefault()
      if (!this.isDisabled(trigger)) this.open(menu, { focus: "first" })
    } else if (event.key === "ArrowUp" && !this.vertical) {
      event.preventDefault()
      if (!this.isDisabled(trigger)) this.open(menu, { focus: "last" })
    } else if (event.key === "Home" || event.key === "End") {
      event.preventDefault()
      const triggers = this.enabledTriggers
      this.moveToTrigger(event.key === "Home" ? triggers[0] : triggers[triggers.length - 1])
    } else if (event.key === "Escape" && this.openMenu) {
      event.preventDefault()
      this.closeAll({ focusTrigger: true })
    }
  }

  menuKey(event, menuElement) {
    const items = this.itemsIn(menuElement)
    const current = event.target.closest(ITEM)
    const index = items.indexOf(current)
    const isSubContent = menuElement.matches("[data-slot=menubar-sub-content]")

    switch (event.key) {
      case "ArrowDown":
      case "ArrowUp": {
        event.preventDefault()
        const step = event.key === "ArrowDown" ? 1 : -1
        const next = index === -1 ? (step > 0 ? items[0] : items[items.length - 1]) : items[(index + step + items.length) % items.length]
        next?.focus()
        break
      }
      case "Home":
      case "End":
        event.preventDefault()
        ;(event.key === "Home" ? items[0] : items[items.length - 1])?.focus()
        break
      case "Enter":
      case " ":
        if (current) {
          event.preventDefault()
          if (current.matches("[data-slot=menubar-sub-trigger]")) {
            this.openSub(this.subFor(current), { focus: true })
          } else {
            current.tagName === "A" ? current.click() : this.activate(current)
          }
        }
        break
      case "Escape":
        event.preventDefault()
        if (isSubContent) {
          const sub = menuElement.closest("[data-slot=menubar-sub]")
          this.closeSub(sub)
          this.subTriggerFor(sub).focus()
        } else {
          this.closeAll({ focusTrigger: true })
        }
        break
      case "Tab":
        this.closeAll()
        break
      default:
        if (event.key === this.forwardKey) {
          event.preventDefault()
          if (current?.matches("[data-slot=menubar-sub-trigger]") && !this.isDisabled(current)) {
            this.openSub(this.subFor(current), { focus: true })
          } else if (!isSubContent && !this.vertical) {
            this.moveToTrigger(this.siblingTrigger(this.triggerFor(this.openMenu), 1), { focus: "first" })
          }
        } else if (event.key === this.backKey) {
          event.preventDefault()
          if (isSubContent) {
            const sub = menuElement.closest("[data-slot=menubar-sub]")
            this.closeSub(sub)
            this.subTriggerFor(sub).focus()
          } else if (!this.vertical) {
            this.moveToTrigger(this.siblingTrigger(this.triggerFor(this.openMenu), -1), { focus: "first" })
          } else {
            this.closeAll({ focusTrigger: true })
          }
        } else if (event.key.length === 1 && !event.metaKey && !event.ctrlKey && !event.altKey) {
          this.typeahead(event.key, items, index)
        }
    }
  }

  // Jump to the next item whose label starts with what was typed in the last half second
  typeahead(key, items, index) {
    clearTimeout(this.typeTimer)
    this.typed += key.toLowerCase()
    this.typeTimer = setTimeout(() => { this.typed = "" }, 500)

    const ordered = [ ...items.slice(index + 1), ...items.slice(0, index + 1) ]
    const match = ordered.find(item => this.labelOf(item).startsWith(this.typed)) ||
      ordered.find(item => this.labelOf(item).startsWith(key.toLowerCase()))
    match?.focus()
  }

  // Pointer (delegated, so items stay plain markup)

  pointerMove(event) {
    if (event.pointerType === "touch") return
    const item = event.target.closest(ITEM)
    if (!item || !item.closest("[role=menu]") || this.isDisabled(item)) return

    if (document.activeElement !== item) item.focus({ preventScroll: true })

    clearTimeout(this.hoverTimer)
    const level = item.closest("[role=menu]")
    this.hoverTimer = setTimeout(() => {
      if (item.matches("[data-slot=menubar-sub-trigger]")) {
        this.openSub(this.subFor(item))
      } else {
        this.openSubsIn(level).forEach(sub => this.closeSub(sub))
      }
    }, HOVER_DELAY)
  }

  click(event) {
    const item = event.target.closest(ITEM)
    if (!item || !item.closest("[role=menu]") || this.isDisabled(item)) return

    if (item.matches("[data-slot=menubar-sub-trigger]")) {
      this.openSub(this.subFor(item))
    } else {
      this.activate(item)
    }
  }

  // Keeps data-highlighted on the focused item and the roving tabindex on triggers
  highlight(event) {
    const target = event.target
    if (target.matches("[data-slot=menubar-trigger]")) {
      this.setRoving(target)
    } else if (target.matches(ITEM)) {
      target.closest("[role=menu]").querySelectorAll("[data-highlighted]").forEach(item => item.removeAttribute("data-highlighted"))
      target.setAttribute("data-highlighted", "")
    }
  }

  // Selecting items

  activate(item) {
    if (this.isDisabled(item)) return

    if (item.getAttribute("role") === "menuitemcheckbox") {
      const checked = item.getAttribute("aria-checked") !== "true"
      this.setChecked(item, checked)
      this.dispatch("checked-change", { detail: { item, checked } })
    } else if (item.getAttribute("role") === "menuitemradio") {
      const group = item.closest("[data-slot=menubar-radio-group]")
      group.querySelectorAll("[role=menuitemradio]").forEach(radio => this.setChecked(radio, radio === item))
      group.dataset.value = item.dataset.value
      this.dispatch("value-change", { detail: { group, value: item.dataset.value } })
    }

    this.dispatch("select", { detail: { item, label: (item.dataset.label || item.textContent).trim() } })
    if (item.dataset.close === "true") this.closeAll({ focusTrigger: true })
  }

  setChecked(item, checked) {
    item.setAttribute("aria-checked", String(checked))
    ;[ item, item.querySelector("[data-slot$=-indicator]") ].forEach(element => {
      element?.toggleAttribute("data-checked", checked)
      element?.toggleAttribute("data-unchecked", !checked)
    })
  }

  // Opening and closing

  open(menu, { focus = "trigger" } = {}) {
    if (this.openMenu && this.openMenu !== menu) this.closeMenu(this.openMenu, { instant: true })

    const trigger = this.triggerFor(menu)
    const content = this.contentFor(menu)
    this.openMenu = menu
    trigger.setAttribute("aria-expanded", "true")
    trigger.toggleAttribute("data-popup-open", true)
    this.show(content)
    this.place(content, this.vertical ? "vertical" : "horizontal")
    this.setRoving(trigger)

    if (focus === "first") this.itemsIn(content)[0]?.focus()
    else if (focus === "last") this.itemsIn(content).at(-1)?.focus()
    else trigger.focus({ preventScroll: true })

    this.dispatch("open-change", { detail: { menu, open: true } })
  }

  closeAll({ focusTrigger = false } = {}) {
    if (!this.openMenu) return
    const menu = this.openMenu
    this.closeMenu(menu)
    this.openMenu = null
    if (focusTrigger) this.triggerFor(menu).focus({ preventScroll: true })
  }

  closeMenu(menu, { instant = false } = {}) {
    const trigger = this.triggerFor(menu)
    const content = this.contentFor(menu)
    this.openSubsIn(content).forEach(sub => this.closeSub(sub, { instant: true }))
    trigger.setAttribute("aria-expanded", "false")
    trigger.removeAttribute("data-popup-open")
    content.querySelectorAll("[data-highlighted]").forEach(item => item.removeAttribute("data-highlighted"))
    this.hide(content, { instant })
    this.dispatch("open-change", { detail: { menu, open: false } })
  }

  openSub(sub, { focus = false } = {}) {
    if (!sub) return
    const trigger = this.subTriggerFor(sub)
    const content = this.subContentFor(sub)

    // Only one submenu per level
    this.openSubsIn(sub.parentElement.closest("[role=menu]")).filter(open => open !== sub).forEach(open => this.closeSub(open, { instant: true }))

    if (content.hidden) {
      trigger.setAttribute("aria-expanded", "true")
      trigger.toggleAttribute("data-popup-open", true)
      this.show(content)
      this.place(content, "sub")
    }
    if (focus) this.itemsIn(content)[0]?.focus()
  }

  closeSub(sub, { instant = false } = {}) {
    const content = this.subContentFor(sub)
    if (content.hidden) return
    this.openSubsIn(content).forEach(nested => this.closeSub(nested, { instant: true }))
    const trigger = this.subTriggerFor(sub)
    trigger.setAttribute("aria-expanded", "false")
    trigger.removeAttribute("data-popup-open")
    this.hide(content, { instant })
  }

  // Enter/exit transitions via Appica's data-starting-style / data-ending-style classes
  show(content) {
    content.toggleAttribute("data-open", true)
    content.removeAttribute("data-ending-style")
    content.hidden = false
    content.setAttribute("data-starting-style", "")
    getComputedStyle(content).opacity
    content.removeAttribute("data-starting-style")
  }

  hide(content, { instant = false } = {}) {
    content.removeAttribute("data-open")
    if (instant || this.reducedMotion) {
      content.hidden = true
      return
    }
    content.setAttribute("data-ending-style", "")
    setTimeout(() => {
      content.removeAttribute("data-ending-style")
      if (!content.hasAttribute("data-open")) content.hidden = true
    }, 100)
  }

  // Flip to the other side when the popup doesn't fit in the viewport
  place(content, kind) {
    content.removeAttribute("data-side")
    const rect = content.getBoundingClientRect()

    if (kind === "horizontal") {
      const spaceAbove = this.triggerFor(this.openMenu).getBoundingClientRect().top
      if (rect.bottom > window.innerHeight && spaceAbove > rect.height) content.dataset.side = "top"
    } else if (kind === "vertical") {
      if (this.rtl ? rect.left < 0 : rect.right > window.innerWidth) content.dataset.side = "bottom"
    } else if (this.rtl ? rect.left < 0 : rect.right > window.innerWidth) {
      content.dataset.side = "inline-start"
    }
  }

  // Helpers

  get enabledTriggers() {
    return this.triggerTargets.filter(trigger => !this.isDisabled(trigger))
  }

  get vertical() {
    return this.element.dataset.orientation === "vertical"
  }

  get rtl() {
    return getComputedStyle(this.element).direction === "rtl"
  }

  get forwardKey() {
    return this.rtl ? "ArrowLeft" : "ArrowRight"
  }

  get backKey() {
    return this.rtl ? "ArrowRight" : "ArrowLeft"
  }

  // [next, previous] keys along the bar
  get barKeys() {
    return this.vertical ? [ "ArrowDown", "ArrowUp" ] : [ this.forwardKey, this.backKey ]
  }

  siblingTrigger(trigger, step) {
    const triggers = this.enabledTriggers
    const index = triggers.indexOf(trigger)
    const next = index + step
    if (next < 0 || next >= triggers.length) return this.loopValue ? triggers[(next + triggers.length) % triggers.length] : null
    return triggers[next]
  }

  moveToTrigger(trigger, { focus = "trigger" } = {}) {
    if (!trigger) return
    if (this.openMenu) {
      this.open(this.menuFor(trigger), { focus })
    } else {
      this.setRoving(trigger)
      trigger.focus()
    }
  }

  setRoving(active) {
    this.triggerTargets.forEach(trigger => trigger.setAttribute("tabindex", trigger === active ? "0" : "-1"))
  }

  // Items that belong to this menu level (not to a nested submenu)
  itemsIn(menuElement) {
    return [ ...menuElement.querySelectorAll(ITEM) ].filter(item => item.closest("[role=menu]") === menuElement && !this.isDisabled(item))
  }

  openSubsIn(menuElement) {
    if (!menuElement) return []
    return [ ...menuElement.querySelectorAll("[data-slot=menubar-sub]") ].filter(sub =>
      sub.parentElement.closest("[role=menu]") === menuElement && !this.subContentFor(sub).hidden)
  }

  // Lower-cased text used for typeahead matching
  labelOf(item) {
    return (item.dataset.label || item.textContent).trim().toLowerCase()
  }

  isDisabled(element) {
    return element.hasAttribute("data-disabled")
  }

  menuFor(trigger) { return trigger.closest("[data-slot=menubar-menu]") }
  triggerFor(menu) { return menu.querySelector(":scope > [data-slot=menubar-trigger]") }
  contentFor(menu) { return menu.querySelector(":scope > [data-slot=menubar-content]") }
  subFor(trigger) { return trigger.closest("[data-slot=menubar-sub]") }
  subTriggerFor(sub) { return sub.querySelector(":scope > [data-slot=menubar-sub-trigger]") }
  subContentFor(sub) { return sub.querySelector(":scope > [data-slot=menubar-sub-content]") }

  get reducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }
}
