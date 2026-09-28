import { Controller } from "@hotwired/stimulus"

// Behaviour for AppicaUI::Collapsible (Base UI's Collapsible in Appica's React version): toggles
// the open state and animates the panel's height through --collapsible-panel-height, using
// Appica's data-starting-style / data-ending-style classes.
//
// Actions: `appica-ui--collapsible#toggle`, `#open`, `#close` (put them on any button inside the root).
// Emits `appica-ui--collapsible:open-change` with { open }.
export default class extends Controller {
  static targets = [ "trigger", "content" ]
  static values = { open: Boolean, disabled: Boolean }

  toggle() {
    if (!this.disabledValue) this.openValue = !this.openValue
  }

  open() {
    if (!this.disabledValue) this.openValue = true
  }

  close() {
    if (!this.disabledValue) this.openValue = false
  }

  // Find-in-page found a match inside a hidden="until-found" panel
  reveal() {
    this.openValue = true
  }

  // Stimulus runs change callbacks once before connect() (with the default as the previous
  // value); the server already rendered that state, so only react once connected
  connect() {
    this.connected = true
  }

  disconnect() {
    this.connected = false
  }

  openValueChanged(open) {
    if (!this.connected) return

    this.setState(open)
    this.contentTargets.forEach(content => open ? this.expand(content) : this.collapse(content))
    this.dispatch("open-change", { detail: { open } })
  }

  setState(open) {
    ;[ this.element, ...this.contentTargets ].forEach(element => {
      element.toggleAttribute("data-open", open)
      element.toggleAttribute("data-closed", !open)
    })
    this.triggerTargets.forEach(trigger => {
      trigger.setAttribute("aria-expanded", String(open))
      trigger.toggleAttribute("data-panel-open", open)
    })
  }

  expand(content) {
    content.removeAttribute("data-ending-style")
    content.hidden = false
    content.style.setProperty("--collapsible-panel-height", `${content.scrollHeight}px`)

    this.animate(content, "data-starting-style", () => {
      content.style.setProperty("--collapsible-panel-height", "auto")
    })
  }

  collapse(content) {
    content.style.setProperty("--collapsible-panel-height", `${content.scrollHeight}px`)
    getComputedStyle(content).height

    content.setAttribute("data-ending-style", "")
    this.whenDone(content, () => {
      if (this.openValue) return
      content.removeAttribute("data-ending-style")
      content.style.setProperty("--collapsible-panel-height", "auto")
      if (content.hasAttribute("data-hidden-until-found")) content.setAttribute("hidden", "until-found")
      else content.hidden = true
    })
  }

  // Commit the starting height (0), then drop it so the panel transitions to its full height
  animate(content, attribute, done) {
    content.setAttribute(attribute, "")
    getComputedStyle(content).height
    content.removeAttribute(attribute)
    this.whenDone(content, done)
  }

  whenDone(content, done) {
    if (this.reducedMotion) return done()

    const finish = event => {
      if (event && (event.target !== content || event.propertyName !== "height")) return
      clearTimeout(timer)
      content.removeEventListener("transitionend", finish)
      done()
    }
    const timer = setTimeout(finish, 500)
    content.addEventListener("transitionend", finish)
  }

  get reducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }
}
