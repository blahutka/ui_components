import { Controller } from "@hotwired/stimulus"

// Behaviour for AppicaUI::Toaster (Base UI's Toast viewport in Appica's React version):
//
// - toasts come from the server (flash, Turbo Stream appends) or from `AppicaUI.toast.add(...)`,
//   which clones the server-rendered <template>s
// - a stack per viewport: newest in front, older ones peek behind and shrink; hovering or
//   focusing the stack expands it (data-expanded) and pauses the timers
// - auto-dismiss after `timeout` (per toast, else the Toaster's), swipe toward the edge to
//   dismiss, at most `limit` visible (the rest wait, data-limited)
// - buttons with data-toast='{"title":…}' anywhere on the page fire a toast (AppicaUI::ToastTrigger)
//
// Emits `appica-ui--toaster:close` with { id } when a toast is removed.
const SWIPE_THRESHOLD = 40
const EXIT_DURATION = 500

export default class extends Controller {
  static targets = [ "viewport", "toast", "template", "iconTemplate" ]
  static values = { position: String, timeout: Number, limit: Number, progress: Boolean }

  connect() {
    this.handlers = new Map()
    this.onAdd = event => this.add(event.detail)
    this.onUpdate = event => this.update(event.detail.id, event.detail.options)
    this.onClose = event => this.close(document.getElementById(event.detail.id))
    this.onBlur = () => this.toastTargets.forEach(toast => this.pause(toast))
    this.onFocus = () => this.toastTargets.forEach(toast => this.resume(toast))

    window.addEventListener("appica-ui--toast:add", this.onAdd)
    window.addEventListener("appica-ui--toast:update", this.onUpdate)
    window.addEventListener("appica-ui--toast:close", this.onClose)
    window.addEventListener("blur", this.onBlur)
    window.addEventListener("focus", this.onFocus)
  }

  disconnect() {
    window.removeEventListener("appica-ui--toast:add", this.onAdd)
    window.removeEventListener("appica-ui--toast:update", this.onUpdate)
    window.removeEventListener("appica-ui--toast:close", this.onClose)
    window.removeEventListener("blur", this.onBlur)
    window.removeEventListener("focus", this.onFocus)
    this.toastTargets.forEach(toast => clearTimeout(toast.timer))
  }

  // Server-rendered, Turbo-appended or JS-built: every toast enters here
  toastTargetConnected(toast) {
    const viewport = toast.closest("[data-slot=toast-viewport]")
    if (!viewport) return

    toast.dataset.side = viewport.dataset.position.startsWith("top") ? "top" : "bottom"
    if (viewport.hasAttribute("data-expanded")) toast.setAttribute("data-expanded", "")

    toast.setAttribute("data-starting-style", "")
    this.layout(viewport)
    getComputedStyle(toast).transform
    toast.removeAttribute("data-starting-style")
    this.startTimer(toast)
  }

  toastTargetDisconnected(toast) {
    clearTimeout(toast.timer)
    this.viewportTargets.forEach(viewport => this.layout(viewport))
  }

  // API

  add(options) {
    const viewport = this.viewportFor(options.position)
    viewport.append(this.build(options))
  }

  update(id, options) {
    const toast = document.getElementById(id)
    if (!toast) return

    const merged = { ...toast.toastOptions, ...options }
    if (options.timeout === null) delete merged.timeout
    const fresh = this.build(merged)

    toast.replaceChildren(...fresh.childNodes)
    ;[ "role", "data-type", "data-timeout", "aria-describedby" ].forEach(name => {
      fresh.hasAttribute(name) ? toast.setAttribute(name, fresh.getAttribute(name)) : toast.removeAttribute(name)
    })
    toast.toastOptions = merged

    clearTimeout(toast.timer)
    this.layout(toast.parentElement)
    this.startTimer(toast)
  }

  close(toast, { swipe } = {}) {
    if (!toast || toast.hasAttribute("data-ending-style")) return

    clearTimeout(toast.timer)
    if (swipe) toast.dataset.swipeDirection = swipe
    toast.setAttribute("data-ending-style", "")
    this.layout(toast.parentElement)

    const remove = () => {
      toast.toastOptions?.onClose?.()
      this.handlers.delete(toast.id)
      this.dispatch("close", { detail: { id: toast.id } })
      toast.remove()
    }
    this.reducedMotion ? remove() : setTimeout(remove, EXIT_DURATION)
  }

  // Actions

  dismiss(event) {
    this.close(event.currentTarget.closest("[data-slot=toast]"))
  }

  act(event) {
    const toast = event.currentTarget.closest("[data-slot=toast]")
    const button = event.currentTarget

    this.handlers.get(toast.id)?.(event)
    if (button.dataset.followUp) this.add(JSON.parse(button.dataset.followUp))
    if (button.dataset.event) window.dispatchEvent(new CustomEvent(button.dataset.event, { detail: { toast: toast.id } }))
    this.close(toast)
  }

  // AppicaUI::ToastTrigger: any element with data-toast='{…}' fires a toast
  trigger(event) {
    const trigger = event.target.closest("[data-toast]")
    if (trigger && !trigger.closest("[data-slot=toast]")) this.add(JSON.parse(trigger.dataset.toast))
  }

  expand(event) {
    const viewport = event.currentTarget
    viewport.setAttribute("data-expanded", "")
    this.toastsIn(viewport).forEach(toast => {
      toast.setAttribute("data-expanded", "")
      toast.querySelector("[data-slot=toast-close]")?.setAttribute("aria-hidden", "false")
      this.pause(toast)
    })
    this.layout(viewport)
  }

  collapse(event) {
    const viewport = event.currentTarget
    if (event.type === "focusout" && viewport.contains(event.relatedTarget)) return
    if (event.type === "focusout" && viewport.matches(":hover")) return
    if (event.type === "pointerleave" && viewport.contains(document.activeElement)) return

    viewport.removeAttribute("data-expanded")
    this.toastsIn(viewport).forEach(toast => {
      toast.removeAttribute("data-expanded")
      toast.querySelector("[data-slot=toast-close]")?.setAttribute("aria-hidden", "true")
      this.resume(toast)
    })
    this.layout(viewport)
  }

  // Stacking: newest first; heights, offsets and the frontmost height drive Appica's classes

  layout(viewport) {
    if (!viewport) return
    const toasts = this.toastsIn(viewport).filter(toast => !toast.hasAttribute("data-ending-style")).reverse()
    let offset = 0

    toasts.forEach((toast, index) => {
      toast.style.height = "auto"
      const height = toast.offsetHeight
      toast.style.height = ""

      toast.style.setProperty("--toast-index", index)
      toast.style.setProperty("--toast-height", `${height}px`)
      toast.style.setProperty("--toast-offset-y", `${offset}px`)
      offset += height

      const limited = index >= this.limitValue
      const wasLimited = toast.hasAttribute("data-limited")
      toast.toggleAttribute("data-limited", limited)
      if (limited) this.pause(toast)
      else if (wasLimited) this.resume(toast)
    })

    const front = toasts[0]
    if (front) viewport.style.setProperty("--toast-frontmost-height", front.style.getPropertyValue("--toast-height"))
  }

  // Timers

  startTimer(toast) {
    const timeout = toast.dataset.timeout !== undefined ? Number(toast.dataset.timeout) : this.timeoutValue
    toast.remaining = timeout
    if (timeout > 0) this.resume(toast)
  }

  resume(toast) {
    if (!(toast.remaining > 0) || toast.hasAttribute("data-limited") || toast.hasAttribute("data-expanded")) return
    clearTimeout(toast.timer)
    toast.startedAt = Date.now()
    toast.timer = setTimeout(() => this.close(toast), toast.remaining)
  }

  pause(toast) {
    if (!toast.timer) return
    clearTimeout(toast.timer)
    toast.timer = null
    toast.remaining -= Date.now() - toast.startedAt
  }

  // Swipe toward the nearest edge(s) to dismiss

  swipeStart(event) {
    if (event.button !== 0 || event.target.closest("button, a, input")) return
    const toast = event.currentTarget
    const allowed = this.swipeDirections(toast.closest("[data-slot=toast-viewport]").dataset.position)
    const start = { x: event.clientX, y: event.clientY }
    let axis = null

    const move = moveEvent => {
      const dx = moveEvent.clientX - start.x
      const dy = moveEvent.clientY - start.y
      if (!axis && Math.hypot(dx, dy) > 5) axis = Math.abs(dx) > Math.abs(dy) ? "x" : "y"
      if (!axis) return

      const delta = axis === "x" ? dx : dy
      const direction = axis === "x" ? (delta > 0 ? "right" : "left") : (delta > 0 ? "down" : "up")
      // Against an allowed direction the toast only gives a little
      const distance = allowed.includes(direction) ? delta : Math.sign(delta) * Math.sqrt(Math.abs(delta))
      toast.setAttribute("data-swiping", "")
      toast.style.setProperty(`--toast-swipe-movement-${axis}`, `${distance}px`)
      toast.swipe = { direction, distance: Math.abs(delta), allowed: allowed.includes(direction) }
    }

    const end = () => {
      window.removeEventListener("pointermove", move)
      window.removeEventListener("pointerup", end)
      window.removeEventListener("pointercancel", end)
      toast.removeAttribute("data-swiping")

      const swipe = toast.swipe
      toast.swipe = null
      if (swipe?.allowed && swipe.distance > SWIPE_THRESHOLD) {
        this.close(toast, { swipe: swipe.direction })
      } else {
        toast.style.setProperty("--toast-swipe-movement-x", "0px")
        toast.style.setProperty("--toast-swipe-movement-y", "0px")
      }
    }

    window.addEventListener("pointermove", move)
    window.addEventListener("pointerup", end)
    window.addEventListener("pointercancel", end)
  }

  swipeDirections(position) {
    const [ vertical, horizontal ] = position.split("-")
    const directions = [ vertical === "top" ? "up" : "down" ]
    if (horizontal === "left") directions.push("left")
    if (horizontal === "right") directions.push("right")
    return directions
  }

  // Building toasts from the templates

  build(options) {
    const toast = this.templateTarget.content.firstElementChild.cloneNode(true)
    const id = options.id || `toast-${Date.now().toString(36)}`
    const timeout = options.timeout ?? this.timeoutValue

    toast.id = id
    toast.toastOptions = options
    toast.setAttribute("role", options.priority === "high" ? "alert" : "dialog")
    toast.setAttribute("aria-labelledby", `${id}-title`)
    if (options.type) toast.dataset.type = options.type
    if (options.timeout !== undefined && options.timeout !== null) toast.dataset.timeout = options.timeout
    else delete toast.dataset.timeout

    const title = toast.querySelector("[data-slot=toast-title]")
    title.id = `${id}-title`
    title.textContent = options.title || ""

    const description = toast.querySelector("[data-slot=toast-description]")
    if (options.description) {
      description.id = `${id}-description`
      description.textContent = options.description
      toast.setAttribute("aria-describedby", description.id)
    } else {
      description.remove()
      toast.removeAttribute("aria-describedby")
    }

    const icon = toast.querySelector("[data-slot=toast-icon]")
    const iconTemplate = options.icon && this.iconTemplateTargets.find(template =>
      template.dataset.kind === options.icon && template.dataset.thumbnail === String(!!options.thumbnail))
    iconTemplate ? icon.replaceChildren(iconTemplate.content.cloneNode(true)) : icon.remove()

    const actions = toast.querySelector("[data-slot=toast-actions]")
    if (options.action?.label) {
      const button = actions.querySelector("[data-slot=toast-action]")
      button.textContent = options.action.label
      if (options.action.toast) button.dataset.followUp = JSON.stringify(options.action.toast)
      if (options.action.event) button.dataset.event = options.action.event
      if (typeof options.action.onClick === "function") this.handlers.set(id, options.action.onClick)
    } else {
      actions.remove()
    }

    if (options.dismissible === false) toast.querySelector("[data-slot=toast-close]").remove()

    const progress = toast.querySelector("[data-slot=toast-progress]")
    if (this.progressValue && timeout > 0) {
      progress.querySelector("[data-slot=toast-progress-indicator]").style.animationDuration = `${timeout}ms`
    } else {
      progress.remove()
    }

    return toast
  }

  viewportFor(position) {
    return this.viewportTargets.find(viewport => viewport.dataset.position === (position || this.positionValue)) ||
      this.viewportTargets.find(viewport => viewport.dataset.position === this.positionValue)
  }

  toastsIn(viewport) {
    return [ ...viewport.querySelectorAll(":scope > [data-slot=toast]") ]
  }

  get reducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }
}
