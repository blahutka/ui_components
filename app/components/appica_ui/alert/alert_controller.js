import { Controller } from "@hotwired/stimulus"

// Dismissal for AppicaUI::Alert: the close button shrinks, blurs and collapses the alert away.
// Lives on the alert's outer box (the one that animates).
//
// Actions: `appica-ui--alert#dismiss`, `#show`. Or drive it from outside by setting
// `data-appica-ui--alert-open-value` to "true" / "false". Emits `appica-ui--alert:open-change` with { open }.
// With a persist key the dismissal is remembered in local (or session) storage.
export default class extends Controller {
  static values = { open: { type: Boolean, default: true }, persistKey: String, persistStorage: { type: String, default: "local" } }

  static duration = 450

  connect() {
    if (this.hasPersistKeyValue && this.storage?.getItem(this.storageKey)) {
      this.element.hidden = true
      this.openValue = false
    }
    this.shown = !this.element.hidden
    this.connected = true
  }

  disconnect() {
    this.connected = false
  }

  dismiss() {
    this.openValue = false
  }

  show() {
    this.openValue = true
  }

  // Stimulus runs change callbacks once before connect(); the server already rendered that
  // state, so only animate changes once connected
  openValueChanged(open) {
    if (!this.connected || open === this.shown) return

    this.shown = open
    open ? this.enter() : this.exit()
    this.remember(open)
    this.dispatch("open-change", { detail: { open } })
  }

  exit() {
    this.animate(this.frames(this.element.offsetHeight), () => this.element.hidden = true)
  }

  enter() {
    this.element.hidden = false
    this.animate(this.frames(this.element.scrollHeight).reverse().map(frame => ({ ...frame, offset: 1 - frame.offset })))
  }

  // Scale down first, then fade + blur while the height collapses (Appica's motion sequence)
  frames(height) {
    return [
      { transform: "scale(1)", opacity: 1, filter: "blur(0px)", height: `${height}px`, offset: 0 },
      { transform: "scale(0.9)", opacity: 1, filter: "blur(0px)", height: `${height}px`, offset: 0.5 },
      { transform: "scale(0.88)", opacity: 0, filter: "blur(12px)", height: "0px", offset: 1 }
    ]
  }

  animate(keyframes, done = () => {}) {
    this.animation?.cancel()

    if (matchMedia("(prefers-reduced-motion: reduce)").matches || !this.element.animate) return done()

    const animation = this.animation = this.element.animate(keyframes, { duration: this.constructor.duration, easing: "cubic-bezier(0.32, 0.72, 0, 1)" })
    let finished = false
    const finish = () => {
      if (finished || animation !== this.animation) return
      finished = true
      done()
      animation.cancel()
    }
    this.animation.finished.then(finish, () => {})
    // Timelines stall in background tabs - settle anyway
    setTimeout(finish, this.constructor.duration + 100)
  }

  remember(open) {
    if (!this.hasPersistKeyValue || !this.storage) return

    try {
      open ? this.storage.removeItem(this.storageKey) : this.storage.setItem(this.storageKey, "dismissed")
    } catch {}
  }

  get storage() {
    try {
      return this.persistStorageValue === "session" ? window.sessionStorage : window.localStorage
    } catch {
      return null
    }
  }

  get storageKey() {
    return `ui-alert:${this.persistKeyValue}`
  }
}
