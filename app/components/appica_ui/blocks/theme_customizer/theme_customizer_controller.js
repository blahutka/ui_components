import { Controller } from "@hotwired/stimulus"
import { DEFAULT_THEME, applyTheme, isCustomColor, loadTheme, overridesCss, resetTheme, saveTheme } from "appica_ui/blocks/theme_customizer/theme"

// Behaviour for AppicaUI::Blocks::ThemeCustomizer: restores the stored theme into the controls, and on every
// change applies it to the page, stores it (other pages and frames follow through the storage
// event) and refreshes the "Get CSS Code" text.
//
// Emits `appica-ui--blocks--theme-customizer:change` with { theme, css }.

// Read with getAttribute: dataset turns "appica-ui--blocks--theme…" into "blocks-Theme…", not blocksTheme…
const SETTING = "data-appica-ui--blocks--theme-customizer-setting"

export default class extends Controller {
  static targets = [ "mode", "custom", "animations", "css" ]

  connect() {
    this.theme = loadTheme()
    // The Select / ToggleGroup controllers inside connect after this one
    requestAnimationFrame(() => this.restore())
  }

  // Control events

  selectChanged(event) {
    const setting = event.target.getAttribute(SETTING)
    const value = event.detail.value
    if (!setting || value == null || this.restoring) return

    if (value === "custom") {
      this.update({ [setting]: this.customInput(setting).value })
    } else {
      this.update({ [setting]: value })
    }
  }

  modeChanged({ detail: { value } }) {
    const mode = Array.isArray(value) ? value[0] : value
    if (mode && !this.restoring) this.update({ mode })
  }

  customPicked({ target }) {
    const setting = target.dataset.setting
    this.customInput(setting).value = target.value
    this.update({ [setting]: target.value })
  }

  customTyped({ target }) {
    const value = target.value.trim()
    if (!isCustomColor(value)) return

    const picker = this.customPicker(target.dataset.setting)
    if (/^#[0-9a-f]{6}$/i.test(value)) picker.value = value
    this.update({ [target.dataset.setting]: value })
  }

  animationsChanged({ target }) {
    this.update({ disableAnimations: target.checked })
  }

  reset() {
    resetTheme()
    this.theme = { ...DEFAULT_THEME }
    this.restore()
    this.render()
  }

  // State

  update(changes) {
    this.theme = { ...this.theme, ...changes }
    saveTheme(this.theme)
    this.render()
  }

  render() {
    applyTheme(this.theme)
    const css = overridesCss(this.theme)
    if (this.hasCssTarget) this.cssTarget.textContent = css || this.cssTarget.dataset.empty || ""
    this.customTargets.forEach(row => { row.hidden = !isCustomColor(this.theme[row.dataset.setting]) })
    this.dispatch("change", { detail: { theme: this.theme, css } })
  }

  // Puts the stored theme into the controls without echoing their change events back
  restore() {
    this.restoring = true
    if (this.hasCssTarget) this.cssTarget.dataset.empty ||= this.cssTarget.textContent

    this.element.querySelectorAll(`[${SETTING}]`).forEach(element => {
      const setting = element.getAttribute(SETTING)
      const value = this.theme[setting]
      const select = this.application.getControllerForElementAndIdentifier(element, "appica-ui--select")
      if (isCustomColor(value)) {
        this.customInput(setting).value = value
        if (/^#[0-9a-f]{6}$/i.test(value)) this.customPicker(setting).value = value
        select?.setValues([ "custom" ])
      } else {
        select?.setValues([ String(value) ])
      }
    })

    this.modeTarget.querySelectorAll("[data-slot=toggle]").forEach(toggle => {
      const pressed = toggle.value === this.theme.mode
      toggle.setAttribute("aria-pressed", pressed)
      toggle.toggleAttribute("data-pressed", pressed)
    })
    if (this.hasAnimationsTarget) this.animationsTarget.checked = !!this.theme.disableAnimations

    this.restoring = false
    this.render()
  }

  customInput(setting) {
    return this.customTargets.find(row => row.dataset.setting === setting).querySelector("input[type=text], input:not([type])")
  }

  customPicker(setting) {
    return this.customTargets.find(row => row.dataset.setting === setting).querySelector("input[type=color]")
  }
}
