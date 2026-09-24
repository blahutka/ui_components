import { Controller } from "@hotwired/stimulus"
import EmblaCarousel from "embla-carousel"
import Autoplay from "embla-carousel-autoplay"
import AutoScroll from "embla-carousel-auto-scroll"
import Fade from "embla-carousel-fade"
import AutoHeight from "embla-carousel-auto-height"
import { WheelGesturesPlugin } from "embla-carousel-wheel-gestures"

// Behaviour for UI::Carousel: an Embla Carousel engine (the one Appica's React version
// uses) plus the parts around it - arrows, pagination, progress, a thumbnail rail,
// keyboard navigation, ARIA labels, scroll effects and syncing two carousels.
//
// Events: `ui--carousel:init` and `ui--carousel:select` with { index, count, api }.
// Elements with data-ui--carousel-target="current" / "count" show the 1-based position.
export default class extends Controller {
  static targets = [
    "viewport", "container", "slide", "prev", "next",
    "pagination", "bulletTemplate", "progress", "progressIndicator",
    "thumbs", "thumbsViewport", "thumb", "thumbsIndicator",
    "current", "count"
  ]
  static values = { config: Object }

  connect() {
    const { options = {}, plugins = {} } = this.configValue

    this.api = EmblaCarousel(this.viewportTarget, this.emblaOptions(options), this.buildPlugins(plugins))
    this.api.on("init", () => this.refresh())
    this.api.on("reInit", () => this.refresh())
    this.api.on("select", () => this.selected())
    this.api.on("scroll", () => this.scrolled())
    this.api.on("slidesInView", () => this.labelSlides())
    this.api.on("pointerDown", () => this.userInteracted())

    this.setupThumbs()
    this.setupEffect()
    this.setupSync()
    this.refresh()
    this.dispatch("init", { detail: this.detail })
  }

  disconnect() {
    cancelAnimationFrame(this.frame)
    clearTimeout(this.resumeTimer)
    this.unsync?.()
    this.resizeObserver?.disconnect()
    this.thumbsApi?.destroy()
    this.api?.destroy()
  }

  // Actions

  prev() {
    this.userInteracted()
    this.api.scrollPrev(this.reducedMotion)
  }

  next() {
    this.userInteracted()
    this.api.scrollNext(this.reducedMotion)
  }

  goTo(event) {
    this.userInteracted()
    this.api.scrollTo(Number(event.currentTarget.dataset.index), this.reducedMotion)
  }

  selectThumb(event) {
    const index = this.thumbTargets.indexOf(event.currentTarget)
    const target = event.currentTarget.dataset.index ? Number(event.currentTarget.dataset.index) : index
    this.userInteracted()
    this.api.scrollTo(target, this.reducedMotion)
  }

  // Arrow keys on the focused viewport (the Accessibility plugin in Embla v9)
  navigate(event) {
    const vertical = this.api.internalEngine().options.axis === "y"
    const rtl = this.api.internalEngine().options.direction === "rtl"
    const back = vertical ? "ArrowUp" : (rtl ? "ArrowRight" : "ArrowLeft")
    const forward = vertical ? "ArrowDown" : (rtl ? "ArrowLeft" : "ArrowRight")

    if (event.key === back) { event.preventDefault(); this.prev() }
    if (event.key === forward) { event.preventDefault(); this.next() }
    if (event.key === "Home") { event.preventDefault(); this.api.scrollTo(0, this.reducedMotion) }
    if (event.key === "End") { event.preventDefault(); this.api.scrollTo(this.api.scrollSnapList().length - 1, this.reducedMotion) }
  }

  // Engine setup

  emblaOptions(options) {
    const direction = getComputedStyle(this.element).direction === "rtl" ? "rtl" : "ltr"
    return { direction, ...options, ...(this.reducedMotion ? { duration: 10 } : {}) }
  }

  buildPlugins(config) {
    const plugins = []

    if (config.autoplay) {
      const { resumeAfter, ...autoplay } = config.autoplay
      this.resumeAfter = resumeAfter
      this.autoplayDelay = autoplay.delay || 4000
      plugins.push(Autoplay({ delay: this.autoplayDelay, stopOnInteraction: !resumeAfter, stopOnMouseEnter: false, ...autoplay }))
    } else if (config.autoScroll && !this.reducedMotion) {
      const { resumeAfter, ...autoScroll } = config.autoScroll
      this.resumeAfter = resumeAfter
      plugins.push(AutoScroll({ stopOnInteraction: !resumeAfter, ...autoScroll }))
    }

    if (config.fade) plugins.push(Fade(config.fade))
    if (config.autoHeight) {
      plugins.push(AutoHeight(config.autoHeight))
      this.containerTarget.classList.add("motion-safe:transition-[height]", "motion-safe:duration-300", "motion-safe:ease-out")
    }
    if (config.wheelGestures) plugins.push(WheelGesturesPlugin(config.wheelGestures))

    return plugins
  }

  // State

  refresh() {
    this.buildPagination()
    this.labelSlides()
    this.selected()
    this.scrolled()
    this.syncAutoplayIndicators()
  }

  selected() {
    const index = this.api.selectedScrollSnap()
    const count = this.api.scrollSnapList().length

    this.paginationTargets.forEach(pagination => {
      pagination.querySelectorAll("[data-slot=carousel-pagination-bullet]").forEach((bullet, bulletIndex) => {
        const active = bulletIndex === index
        bullet.toggleAttribute("data-active", active)
        active ? bullet.setAttribute("aria-current", "true") : bullet.removeAttribute("aria-current")
      })
    })

    this.updateArrows()
    this.updateThumbs(index)
    this.currentTargets.forEach(element => { element.textContent = index + 1 })
    this.countTargets.forEach(element => { element.textContent = count })
    this.dispatch("select", { detail: this.detail })
  }

  scrolled() {
    this.progressTargets.forEach((progress, i) => {
      const source = progress.dataset.source
      if (source === "autoplay" || (source === "auto" && this.autoplayPlaying)) return
      this.setProgress(progress, this.progressIndicatorTargets[i], this.api.scrollProgress())
    })
    this.tweenEffect()
  }

  updateArrows() {
    const loop = this.api.internalEngine().options.loop
    this.prevTargets.forEach(button => this.setDisabled(button, !loop && !this.api.canScrollPrev()))
    this.nextTargets.forEach(button => this.setDisabled(button, !loop && !this.api.canScrollNext()))
  }

  setDisabled(button, disabled) {
    const off = disabled || button.hasAttribute("data-force-disabled")
    button.disabled = off
    button.toggleAttribute("data-disabled", off)
  }

  get detail() {
    return { index: this.api.selectedScrollSnap(), count: this.api.scrollSnapList().length, api: this.api }
  }

  // Pagination: one bullet per snap point, cloned from the server-rendered <template>

  buildPagination() {
    const count = this.api.scrollSnapList().length

    this.paginationTargets.forEach(pagination => {
      const template = pagination.querySelector("template")
      pagination.querySelectorAll("[data-slot=carousel-pagination-bullet]").forEach(bullet => bullet.remove())
      pagination.hidden = count <= 1

      for (let index = 0; index < count; index++) {
        const bullet = template.content.firstElementChild.cloneNode(true)
        bullet.dataset.index = index
        bullet.setAttribute("aria-label", `Go to slide ${index + 1}`)
        bullet.addEventListener("click", event => this.goTo(event))
        pagination.append(bullet)
      }
    })
  }

  // "Slide 1 of 5", or "Slides 1-3 of 6 (group 1 of 2)" when several slides share a snap
  labelSlides() {
    const total = this.slideTargets.length
    const groups = this.api.internalEngine().slideRegistry

    groups.forEach((slides, group) => {
      slides.forEach(slideIndex => {
        const slide = this.slideTargets[slideIndex]
        if (!slide) return
        const label = slides.length > 1
          ? `Slides ${slides[0] + 1}-${slides[slides.length - 1] + 1} of ${total} (group ${group + 1} of ${groups.length})`
          : `Slide ${slideIndex + 1} of ${total}`
        slide.setAttribute("aria-label", label)
      })
    })
  }

  // Progress: scroll position, or the autoplay countdown while autoplay is playing

  setProgress(progress, indicator, value) {
    const fraction = Math.min(1, Math.max(0, value))
    if (!indicator) return

    if (progress.dataset.variant === "circular") {
      indicator.setAttribute("stroke-dashoffset", String(100 - fraction * 100))
    } else {
      indicator.style[progress.dataset.orientation === "vertical" ? "height" : "width"] = `${fraction * 100}%`
    }
  }

  get autoplayPlaying() {
    return !!this.api?.plugins().autoplay?.isPlaying()
  }

  syncAutoplayIndicators() {
    const autoplay = this.api.plugins().autoplay
    if (!autoplay) return

    const tick = () => {
      const playing = autoplay.isPlaying() && !this.reducedMotion
      const remaining = autoplay.timeUntilNext()
      const fraction = playing && remaining !== null ? 1 - remaining / this.autoplayDelay : 0

      this.paginationTargets.forEach(pagination => {
        pagination.toggleAttribute("data-autoplay", playing)
        const fill = pagination.querySelector("[data-active] [data-slot=carousel-pagination-fill]")
        if (fill) fill.style[pagination.dataset.orientation === "vertical" ? "height" : "width"] = `${fraction * 100}%`
      })

      this.progressTargets.forEach((progress, i) => {
        const source = progress.dataset.source
        if (source === "autoplay" || (source === "auto" && playing)) this.setProgress(progress, this.progressIndicatorTargets[i], fraction)
      })

      this.frame = requestAnimationFrame(tick)
    }

    cancelAnimationFrame(this.frame)
    this.frame = requestAnimationFrame(tick)
  }

  // Autoplay / auto scroll: restart a set time after the user takes over (resumeAfter)

  userInteracted() {
    if (!this.resumeAfter) return
    const plugins = this.api.plugins()
    const plugin = plugins.autoplay || plugins.autoScroll
    if (!plugin) return

    plugin.stop()
    clearTimeout(this.resumeTimer)
    this.resumeTimer = setTimeout(() => plugin.play(), this.resumeAfter)
  }

  // Thumbnails: a second, free-dragging engine for the rail and a sliding outline

  setupThumbs() {
    if (!this.hasThumbsViewportTarget) return

    const vertical = this.thumbsTarget.dataset.orientation === "vertical"
    this.thumbsApi = EmblaCarousel(this.thumbsViewportTarget, {
      axis: vertical ? "y" : "x",
      direction: this.api.internalEngine().options.direction,
      align: "start",
      containScroll: "trimSnaps",
      dragFree: true
    })
    this.thumbsApi.on("scroll", () => this.moveThumbsIndicator())
    this.thumbsApi.on("reInit", () => this.moveThumbsIndicator())
    this.resizeObserver = new ResizeObserver(() => this.moveThumbsIndicator())
    this.resizeObserver.observe(this.thumbsTarget)
  }

  updateThumbs(index) {
    if (!this.thumbsApi) return

    this.thumbTargets.forEach((thumb, i) => {
      const active = (thumb.dataset.index ? Number(thumb.dataset.index) : i) === index
      thumb.toggleAttribute("data-active", active)
      active ? thumb.setAttribute("aria-current", "true") : thumb.removeAttribute("aria-current")
      thumb.setAttribute("aria-label", `Go to slide ${i + 1}`)
    })

    // Only travel when the selection leaves the rail's view
    if (!this.thumbsApi.slidesInView().includes(index)) this.thumbsApi.scrollTo(index, this.reducedMotion)
    this.moveThumbsIndicator()
  }

  moveThumbsIndicator() {
    if (!this.hasThumbsIndicatorTarget) return

    const active = this.thumbTargets.find(thumb => thumb.hasAttribute("data-active"))
    if (!active) return

    const rail = this.thumbsTarget.getBoundingClientRect()
    const thumb = active.getBoundingClientRect()
    const indicator = this.thumbsIndicatorTarget
    indicator.style.translate = `${thumb.left - rail.left}px ${thumb.top - rail.top}px`
    indicator.style.width = `${thumb.width}px`
    indicator.style.height = `${thumb.height}px`
  }

  // Scroll effects: `effect: :parallax` drifts [data-carousel-layer] against the scroll,
  // `effect: :scale` shrinks and dims slides by their distance from the snap

  setupEffect() {
    this.effect = this.configValue.effect
    if (!this.effect) return

    this.layers = this.slideTargets.map(slide => slide.querySelector("[data-carousel-layer]") || slide.firstElementChild)
    this.api.on("slideFocus", () => this.tweenEffect())
    this.tweenEffect()
  }

  tweenEffect() {
    if (!this.effect || !this.layers) return

    const engine = this.api.internalEngine()
    const progress = this.api.scrollProgress()
    const inView = this.api.slidesInView()

    this.api.scrollSnapList().forEach((snap, snapIndex) => {
      engine.slideRegistry[snapIndex].forEach(slideIndex => {
        let diff = snap - progress

        if (engine.options.loop) {
          engine.slideLooper.loopPoints.forEach(point => {
            const target = point.target()
            if (slideIndex === point.index && target !== 0) {
              diff = Math.sign(target) === -1 ? snap - (1 + progress) : snap + (1 - progress)
            }
          })
        }

        const layer = this.layers[slideIndex]
        if (!layer || (!inView.includes(slideIndex) && Math.abs(diff) > 1)) return

        if (this.effect === "parallax") {
          layer.style.transform = `translateX(${diff * -1.7 * 100}%)`
        } else if (this.effect === "scale") {
          const tween = 1 - Math.abs(diff * 1.1)
          layer.style.transform = `scale(${Math.min(Math.max(tween, 0.58), 1)})`
          layer.style.opacity = Math.min(Math.max(tween, 0.24), 1)
          layer.style.transformOrigin = diff > 0 ? "left center" : diff < 0 ? "right center" : "center"
        }
      })
    })
  }

  // Syncing: `sync_with:` links this carousel to another by element id, both ways

  setupSync() {
    const id = this.configValue.syncWith
    if (!id) return

    const connect = () => {
      const element = document.getElementById(id)
      const other = element && this.application.getControllerForElementAndIdentifier(element, "ui--carousel")
      if (!other?.api) return false

      const follow = (from, to) => () => {
        const index = from.selectedScrollSnap()
        if (to.selectedScrollSnap() !== index) to.scrollTo(index)
      }
      const toOther = follow(this.api, other.api)
      const fromOther = follow(other.api, this.api)
      this.api.on("select", toOther)
      other.api.on("select", fromOther)
      this.unsync = () => { this.api.off("select", toOther); other.api.off("select", fromOther) }
      return true
    }

    // The other carousel may connect after this one
    if (!connect()) requestAnimationFrame(() => connect())
  }

  get reducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }
}
