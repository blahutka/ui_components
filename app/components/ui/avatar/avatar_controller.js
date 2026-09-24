import { Controller } from "@hotwired/stimulus"

// Image loading for UI::Avatar (Base UI's Avatar in Appica's React version).
//
// The root's data-status moves idle → loading → loaded | error; the Appica classes
// show the image and hide the fallback when it's "loaded". An AvatarFallback with
// data-delay stays hidden for that many ms, so fast loads don't flash the initials.
//
// Emits `ui--avatar:loading-status-change` with { status } (React's onLoadingStatusChange).
export default class extends Controller {
  static targets = [ "image", "fallback" ]

  connect() {
    this.scheduleFallback()

    if (!this.hasImageTarget || !this.imageTarget.getAttribute("src")) {
      this.setStatus("idle")
    } else if (this.imageTarget.complete) {
      // Already resolved (e.g. from cache) before the controller connected
      this.imageTarget.naturalWidth > 0 ? this.loaded() : this.failed()
    } else {
      this.setStatus("loading")
    }
  }

  disconnect() {
    clearTimeout(this.fallbackTimer)
  }

  loaded() {
    this.setStatus("loaded")
  }

  failed() {
    this.setStatus("error")
    this.showFallback()
  }

  // Image targets added later (e.g. a src set by other code) start loading again
  imageTargetConnected(image) {
    if (image.getAttribute("src") && !image.complete) this.setStatus("loading")
  }

  scheduleFallback() {
    this.fallbackTargets.forEach(fallback => {
      const delay = Number(fallback.dataset.delay)
      if (delay > 0) {
        this.fallbackTimer = setTimeout(() => {
          if (this.element.dataset.status !== "loaded") fallback.hidden = false
        }, delay)
      }
    })
  }

  showFallback() {
    clearTimeout(this.fallbackTimer)
    this.fallbackTargets.forEach(fallback => { fallback.hidden = false })
  }

  setStatus(status) {
    if (this.element.dataset.status === status) return
    this.element.dataset.status = status
    this.dispatch("loading-status-change", { detail: { status } })
  }
}
