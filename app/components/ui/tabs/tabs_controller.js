import { Controller } from "@hotwired/stimulus"

// UI::Tabs: selects a tab (click, Enter / Space, or on focus with activate-on-focus), shows its
// panel, keeps one tab stop with arrow-key focus along the orientation (Home / End, wrapping
// unless loop is off), and slides the indicator via --active-tab-* variables.
// Emits `ui--tabs:change` with { value }.
export default class extends Controller {
  static targets = [ "list", "indicator", "trigger", "panel" ]

  connect() {
    this.observer = new ResizeObserver(() => this.place())
    this.listTargets.forEach(list => this.observer.observe(list))
    this.triggerTargets.forEach(trigger => this.observer.observe(trigger))
    // Without a selected tab the first enabled one takes the tab stop
    this.listTargets.forEach(list => {
      const triggers = this.triggersOf(list)
      if (!triggers.some(trigger => trigger.tabIndex === 0)) {
        const first = triggers.find(trigger => !trigger.disabled)
        if (first) first.tabIndex = 0
      }
    })
    this.place()
  }

  disconnect() {
    this.observer?.disconnect()
  }

  select({ currentTarget }) {
    this.activate(currentTarget)
  }

  // Programmatic selection: element.dispatchEvent(new CustomEvent("ui--tabs:select", { detail: { value } }))
  selectValue({ detail: { value } }) {
    const trigger = this.triggerTargets.find(trigger => trigger.dataset.value === String(value))
    if (trigger) this.activate(trigger)
  }

  activate(trigger) {
    if (!trigger || trigger.disabled || trigger.hasAttribute("data-active")) return

    const list = trigger.closest("[role=tablist]")
    const triggers = this.triggersOf(list)
    triggers.forEach(other => {
      const active = other === trigger
      other.toggleAttribute("data-active", active)
      other.setAttribute("aria-selected", active)
      other.tabIndex = active ? 0 : -1
    })

    triggers.forEach(other => {
      const panel = this.panelTargets.find(panel => panel.id === other.getAttribute("aria-controls"))
      if (!panel) return
      const show = other === trigger
      if (show && panel.hidden) {
        panel.setAttribute("data-starting-style", "")
        panel.hidden = false
        requestAnimationFrame(() => panel.removeAttribute("data-starting-style"))
      } else if (!show) {
        panel.hidden = true
      }
    })

    this.place()
    this.dispatch("change", { detail: { value: trigger.dataset.value } })
  }

  focus(event) {
    const trigger = this.triggerTargets.find(trigger => trigger === event.target)
    if (!trigger) return

    const list = trigger.closest("[role=tablist]")
    if (list.dataset.uiTabsActivateOnFocusParam === "true") this.activate(trigger)
  }

  navigate(event) {
    const list = event.currentTarget
    const triggers = this.triggersOf(list).filter(trigger => !trigger.disabled)
    const index = triggers.indexOf(document.activeElement)
    if (index === -1) return

    const vertical = list.dataset.orientation === "vertical"
    const rtl = getComputedStyle(list).direction === "rtl"
    const keys = vertical ? { ArrowUp: -1, ArrowDown: 1 } : { ArrowLeft: rtl ? 1 : -1, ArrowRight: rtl ? -1 : 1 }
    let next

    if (event.key in keys) {
      next = index + keys[event.key]
      next = list.dataset.uiTabsLoopParam === "false" ? Math.max(0, Math.min(triggers.length - 1, next)) : (next + triggers.length) % triggers.length
    } else if (event.key === "Home") next = 0
    else if (event.key === "End") next = triggers.length - 1
    else return

    event.preventDefault()
    triggers.forEach(trigger => trigger.tabIndex = trigger === triggers[next] ? 0 : -1)
    triggers[next].focus()
  }

  // The indicator covers the active tab: offsets from each edge of the list, and its size
  place() {
    this.indicatorTargets.forEach(indicator => {
      const list = indicator.closest("[role=tablist]")
      const active = this.triggersOf(list).find(trigger => trigger.hasAttribute("data-active"))
      if (!active || !active.offsetWidth) return indicator.hidden = true

      const left = active.offsetLeft
      const top = active.offsetTop
      const set = (name, value) => indicator.style.setProperty(`--active-tab-${name}`, `${value}px`)
      set("left", left)
      set("right", list.scrollWidth - left - active.offsetWidth)
      set("top", top)
      set("bottom", list.scrollHeight - top - active.offsetHeight)
      set("width", active.offsetWidth)
      set("height", active.offsetHeight)
      indicator.hidden = false
    })
  }

  triggersOf(list) {
    return this.triggerTargets.filter(trigger => trigger.closest("[role=tablist]") === list)
  }
}
