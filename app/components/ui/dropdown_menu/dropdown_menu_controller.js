import { Controller } from "@hotwired/stimulus"

// UI::DropdownMenu: a menu popup (and submenus) in the top layer.
//
// - trigger: click / Enter / Space / ↓ opens (focusing the first item), ↑ opens on the last;
//   `hover` opens it on hover after `delay` and closes after `closeDelay` once the pointer leaves
// - menu: arrows / Home / End move, Enter / Space select, typeahead, Escape closes a level,
//   → / ← open and close submenus (mirrored in RTL), Tab closes
// - submenus open on hover (after a short delay), click or the arrow key, beside their trigger
// - checkbox and radio items keep their state in aria-checked / data-checked
//
// Events: `select` { item, label }, `checked-change` { item, checked }, `value-change`
// { group, value }, `open-change` { open }. ContextMenu extends this controller.
const ITEM = "[role=menuitem], [role=menuitemcheckbox], [role=menuitemradio]"
const SUB_DELAY = 100

export default class extends Controller {
  static targets = [ "trigger", "content" ]
  static values = { hover: Boolean, delay: { type: Number, default: 100 }, closeDelay: { type: Number, default: 100 } }

  connect() {
    this.slot = this.element.dataset.slot
    this.typed = ""
    this.onOutside = event => { if (this.isOpen && !this.element.contains(event.target) && !this.popups.some(popup => popup.contains(event.target))) this.close() }
    this.onReflow = () => this.reposition()
  }

  disconnect() {
    this.close({ instant: true })
    clearTimeout(this.hoverTimer)
    clearTimeout(this.typeTimer)
  }

  // Trigger

  toggle() {
    if (this.hoverValue && this.isOpen && this.openedByHover) return (this.openedByHover = false)
    this.isOpen ? this.close({ focusTrigger: true }) : this.open({ focus: "content" })
  }

  enter(event) {
    if (!this.hoverValue || event.pointerType === "touch") return
    clearTimeout(this.leaveTimer)
    if (!this.isOpen && this.triggerTarget.contains(event.target)) {
      clearTimeout(this.enterTimer)
      this.enterTimer = setTimeout(() => { this.openedByHover = true; this.open() }, this.delayValue)
    }
  }

  leave(event) {
    if (!this.hoverValue || event.pointerType === "touch") return
    clearTimeout(this.enterTimer)
    this.leaveTimer = setTimeout(() => this.close(), this.closeDelayValue)
  }

  // Keyboard

  key(event) {
    if (this.hasTriggerTarget && event.target === this.triggerTarget) {
      if ([ "ArrowDown", "Enter", " " ].includes(event.key)) {
        event.preventDefault()
        this.open({ focus: "first" })
      } else if (event.key === "ArrowUp") {
        event.preventDefault()
        this.open({ focus: "last" })
      }
      return
    }

    const menu = event.target.closest("[role=menu]")
    if (!menu) return
    const items = this.itemsIn(menu)
    const current = event.target.closest(ITEM)
    const index = items.indexOf(current)
    const isSub = menu !== this.contentTarget

    switch (event.key) {
      case "ArrowDown":
      case "ArrowUp": {
        event.preventDefault()
        const step = event.key === "ArrowDown" ? 1 : -1
        const next = index === -1 ? (step > 0 ? items[0] : items.at(-1)) : items[(index + step + items.length) % items.length]
        next?.focus()
        break
      }
      case "Home":
      case "End":
        event.preventDefault()
        ;(event.key === "Home" ? items[0] : items.at(-1))?.focus()
        break
      case "Enter":
      case " ":
        if (!current) break
        event.preventDefault()
        if (this.isSubTrigger(current)) this.openSub(current, { focus: true })
        else current.tagName === "A" ? current.click() : this.activate(current)
        break
      case "Escape":
        event.preventDefault()
        event.stopPropagation()
        if (isSub) this.closeSub(this.subTriggerOf(menu), { focusTrigger: true })
        else this.close({ focusTrigger: true })
        break
      case "Tab":
        this.close()
        break
      default:
        if (event.key === this.forwardKey && current && this.isSubTrigger(current)) {
          event.preventDefault()
          this.openSub(current, { focus: true })
        } else if (event.key === this.backKey && isSub) {
          event.preventDefault()
          this.closeSub(this.subTriggerOf(menu), { focusTrigger: true })
        } else if (event.key.length === 1 && !event.metaKey && !event.ctrlKey && !event.altKey) {
          this.typeahead(event.key, items, index)
        }
    }
  }

  typeahead(key, items, index) {
    clearTimeout(this.typeTimer)
    this.typed += key.toLowerCase()
    this.typeTimer = setTimeout(() => { this.typed = "" }, 500)
    const ordered = [ ...items.slice(index + 1), ...items.slice(0, index + 1) ]
    const match = ordered.find(item => this.labelOf(item).startsWith(this.typed)) || ordered.find(item => this.labelOf(item).startsWith(key.toLowerCase()))
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
      if (this.isSubTrigger(item)) this.openSub(item)
      else this.openSubTriggersIn(level).forEach(trigger => this.closeSub(trigger))
    }, SUB_DELAY)
  }

  click(event) {
    const item = event.target.closest(ITEM)
    if (!item || !item.closest("[role=menu]") || this.isDisabled(item)) return
    if (this.isSubTrigger(item)) this.openSub(item)
    else this.activate(item)
  }

  highlight(event) {
    const item = event.target.closest?.(ITEM)
    if (!item) return
    item.closest("[role=menu]").querySelectorAll("[data-highlighted]").forEach(other => other.removeAttribute("data-highlighted"))
    item.setAttribute("data-highlighted", "")
  }

  // Selecting

  activate(item) {
    if (this.isDisabled(item)) return
    const role = item.getAttribute("role")

    if (role === "menuitemcheckbox") {
      const checked = item.getAttribute("aria-checked") !== "true"
      this.setChecked(item, checked)
      this.dispatch("checked-change", { detail: { item, checked } })
    } else if (role === "menuitemradio") {
      const group = item.closest(`[data-slot=${this.slot}-radio-group]`)
      group.querySelectorAll("[role=menuitemradio]").forEach(radio => this.setChecked(radio, radio === item))
      group.dataset.value = item.dataset.value
      this.dispatch("value-change", { detail: { group, value: item.dataset.value } })
    }

    this.dispatch("select", { detail: { item, label: (item.dataset.label || item.textContent).trim() } })
    if (item.dataset.close === "true") this.close({ focusTrigger: true })
  }

  setChecked(item, checked) {
    item.setAttribute("aria-checked", String(checked))
    ;[ item, item.querySelector("[data-slot$=-indicator]") ].forEach(element => {
      element?.toggleAttribute("data-checked", checked)
      element?.toggleAttribute("data-unchecked", !checked)
    })
  }

  // Opening and closing

  // `anchor` is an element or a rect ({ left, top, right, bottom }) - ContextMenu passes the pointer
  open({ focus = null, anchor = null } = {}) {
    const content = this.contentTarget
    this.anchor = anchor || (this.hasTriggerTarget ? this.triggerTarget : null)
    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", "true")
      this.triggerTarget.setAttribute("data-popup-open", "")
    }
    if (!this.isOpen) {
      this.show(content)
      document.addEventListener("pointerdown", this.onOutside, true)
      window.addEventListener("resize", this.onReflow)
      window.addEventListener("scroll", this.onReflow, true)
      this.dispatch("open-change", { detail: { open: true } })
    }
    this.place(content, this.anchor)

    const items = this.itemsIn(content)
    if (focus === "first") items[0]?.focus()
    else if (focus === "last") items.at(-1)?.focus()
    else if (focus === "content") content.focus({ preventScroll: true })
  }

  close({ focusTrigger = false, instant = false } = {}) {
    if (!this.isOpen) return
    const content = this.contentTarget
    this.openSubTriggersIn(content).forEach(trigger => this.closeSub(trigger, { instant: true }))
    content.querySelectorAll("[data-highlighted]").forEach(item => item.removeAttribute("data-highlighted"))
    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", "false")
      this.triggerTarget.removeAttribute("data-popup-open")
    }
    this.hide(content, { instant })
    document.removeEventListener("pointerdown", this.onOutside, true)
    window.removeEventListener("resize", this.onReflow)
    window.removeEventListener("scroll", this.onReflow, true)
    this.openedByHover = false
    if (focusTrigger && this.hasTriggerTarget) this.triggerTarget.focus({ preventScroll: true })
    this.dispatch("open-change", { detail: { open: false } })
  }

  openSub(trigger, { focus = false } = {}) {
    if (this.isDisabled(trigger)) return
    const content = this.subContentOf(trigger)
    const level = trigger.closest("[role=menu]")
    this.openSubTriggersIn(level).filter(other => other !== trigger).forEach(other => this.closeSub(other, { instant: true }))

    if (!content.matches(":popover-open")) {
      trigger.setAttribute("aria-expanded", "true")
      trigger.setAttribute("data-popup-open", "")
      this.show(content)
      this.place(content, trigger)
    }
    if (focus) this.itemsIn(content)[0]?.focus()
  }

  closeSub(trigger, { instant = false, focusTrigger = false } = {}) {
    const content = this.subContentOf(trigger)
    if (!content?.matches(":popover-open")) return
    this.openSubTriggersIn(content).forEach(nested => this.closeSub(nested, { instant: true }))
    trigger.setAttribute("aria-expanded", "false")
    trigger.removeAttribute("data-popup-open")
    this.hide(content, { instant })
    if (focusTrigger) trigger.focus()
  }

  show(popup) {
    popup.removeAttribute("data-ending-style")
    clearTimeout(popup.hideTimer)
    if (!popup.matches(":popover-open")) popup.showPopover()
    popup.setAttribute("data-starting-style", "")
    requestAnimationFrame(() => popup.removeAttribute("data-starting-style"))
  }

  hide(popup, { instant = false } = {}) {
    if (!popup.matches(":popover-open")) return
    if (instant || this.reducedMotion) return popup.hidePopover()
    popup.setAttribute("data-ending-style", "")
    popup.hideTimer = setTimeout(() => {
      popup.removeAttribute("data-ending-style")
      popup.hidePopover()
    }, 100)
  }

  reposition() {
    if (!this.isOpen) return
    this.place(this.contentTarget, this.anchor)
    this.openSubTriggersIn(this.contentTarget).forEach(trigger => this.place(this.subContentOf(trigger), trigger))
  }

  // Place against an element or a rect: data-side (bottom / top / inline_end / inline_start /
  // left / right), data-align (start / center / end), offsets; flip and clamp to the viewport
  place(popup, anchor) {
    if (!anchor) return
    const rect = anchor.getBoundingClientRect ? anchor.getBoundingClientRect() : { ...anchor, width: 0, height: 0 }
    const rtl = getComputedStyle(this.element).direction === "rtl"
    const margin = 8
    const offset = Number(popup.dataset.sideOffset || 6)
    const alignOffset = Number(popup.dataset.alignOffset || 0)
    const width = popup.offsetWidth
    const height = popup.offsetHeight
    let side = popup.dataset.side || "bottom"
    if (side === "inline_end") side = rtl ? "left" : "right"
    if (side === "inline_start") side = rtl ? "right" : "left"
    const align = popup.dataset.align || "start"

    const fits = {
      bottom: rect.bottom + offset + height <= window.innerHeight - margin,
      top: rect.top - offset - height >= margin,
      right: rect.right + offset + width <= window.innerWidth - margin,
      left: rect.left - offset - width >= margin
    }
    const opposite = { bottom: "top", top: "bottom", left: "right", right: "left" }
    if (!fits[side] && fits[opposite[side]]) side = opposite[side]

    let top
    let left
    if (side === "bottom" || side === "top") {
      top = side === "bottom" ? rect.bottom + offset : rect.top - offset - height
      const start = rtl ? rect.right - width : rect.left
      left = align === "center" ? rect.left + (rect.width - width) / 2 : align === "end" ? (rtl ? rect.left : rect.right - width) : start
      left += rtl ? -alignOffset : alignOffset
    } else {
      left = side === "right" ? rect.right + offset : rect.left - offset - width
      top = align === "center" ? rect.top + (rect.height - height) / 2 : align === "end" ? rect.bottom - height : rect.top
      top += alignOffset
    }

    left = Math.max(margin, Math.min(left, window.innerWidth - width - margin))
    top = Math.max(margin, Math.min(top, window.innerHeight - height - margin))
    Object.assign(popup.style, { top: `${top}px`, left: `${left}px` })
    popup.style.setProperty("--available-height", `${window.innerHeight - margin * 2}px`)
    popup.style.transformOrigin = { bottom: "top", top: "bottom", right: rtl ? "right top" : "left top", left: rtl ? "left top" : "right top" }[side]
    popup.dataset.currentSide = side
  }

  // Helpers

  get isOpen() {
    return this.hasContentTarget && this.contentTarget.matches(":popover-open") && !this.contentTarget.hasAttribute("data-ending-style")
  }

  get popups() {
    return [ ...this.element.querySelectorAll("[popover]") ]
  }

  itemsIn(menu) {
    return [ ...menu.querySelectorAll(ITEM) ].filter(item => item.closest("[role=menu]") === menu && !this.isDisabled(item))
  }

  isSubTrigger(item) {
    return item.dataset.slot === `${this.slot}-sub-trigger`
  }

  subContentOf(trigger) {
    return document.getElementById(trigger.getAttribute("aria-controls"))
  }

  subTriggerOf(content) {
    return document.getElementById(content.getAttribute("aria-labelledby"))
  }

  openSubTriggersIn(menu) {
    if (!menu) return []
    return [ ...menu.querySelectorAll(`[data-slot=${this.slot}-sub-trigger][aria-expanded=true]`) ].filter(trigger => trigger.closest("[role=menu]") === menu)
  }

  labelOf(item) {
    return (item.dataset.label || item.textContent).trim().toLowerCase()
  }

  isDisabled(element) {
    return element.hasAttribute("data-disabled")
  }

  get forwardKey() {
    return getComputedStyle(this.element).direction === "rtl" ? "ArrowLeft" : "ArrowRight"
  }

  get backKey() {
    return getComputedStyle(this.element).direction === "rtl" ? "ArrowRight" : "ArrowLeft"
  }

  get reducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }
}
