import { Controller } from "@hotwired/stimulus"

// AppicaUI::Toc: scroll-spy. Observes the headings the links point at, marks the links in view
// data-active (the topmost one aria-current="location"; with none in view, the heading nearest
// the top) and moves the rail indicator over the active links. With a container it tracks that
// scrolling element, and clicking a link scrolls it.
export default class extends Controller {
  static targets = [ "list", "link" ]
  static values = { rootMargin: { type: String, default: "0px" }, container: String }

  connect() {
    this.visible = new Set()
    this.observer = new IntersectionObserver(entries => this.update(entries), { root: this.root, rootMargin: this.rootMarginValue })
    this.headings.forEach(heading => this.observer.observe(heading))
    this.resizer = new ResizeObserver(() => this.place())
    this.listTargets.forEach(list => this.resizer.observe(list))
  }

  disconnect() {
    this.observer?.disconnect()
    this.resizer?.disconnect()
  }

  update(entries) {
    entries.forEach(entry => entry.isIntersecting ? this.visible.add(entry.target.id) : this.visible.delete(entry.target.id))

    let active = this.ids.filter(id => this.visible.has(id))
    if (active.length === 0) {
      const top = (entries[0]?.rootBounds || this.root?.getBoundingClientRect() || { top: 0 }).top
      const nearest = this.headings.reduce((best, heading) => {
        const distance = Math.abs(heading.getBoundingClientRect().top - top)
        return !best || distance < best.distance ? { id: heading.id, distance } : best
      }, null)
      if (nearest) active = [ nearest.id ]
    }

    this.linkTargets.forEach(link => {
      const id = this.idOf(link)
      link.toggleAttribute("data-active", active.includes(id))
      id === active[0] ? link.setAttribute("aria-current", "location") : link.removeAttribute("aria-current")
    })
    this.place()
  }

  // The indicator spans the active links
  place() {
    this.listTargets.forEach(list => {
      const links = this.linkTargets.filter(link => list.contains(link) && link.hasAttribute("data-active"))
      if (links.length === 0) return list.removeAttribute("data-visible")

      const top = Math.min(...links.map(link => link.offsetTop))
      const bottom = Math.max(...links.map(link => link.offsetTop + link.offsetHeight))
      list.style.setProperty("--toc-indicator-top", `${top}px`)
      list.style.setProperty("--toc-indicator-height", `${bottom - top}px`)
      list.setAttribute("data-visible", "")
      // Slide only after the first placement, so it doesn't grow in from the top
      if (!list.hasAttribute("data-ready")) requestAnimationFrame(() => list.setAttribute("data-ready", ""))
    })
  }

  scroll(event) {
    const link = event.target.closest("a[href^='#']")
    const heading = link && document.getElementById(this.idOf(link))
    const root = this.root
    if (!heading || !root || !root.contains(heading)) return

    event.preventDefault()
    const gap = parseFloat(getComputedStyle(heading).scrollMarginTop) || 0
    const top = heading.getBoundingClientRect().top - root.getBoundingClientRect().top + root.scrollTop - gap
    const smooth = !window.matchMedia("(prefers-reduced-motion: reduce)").matches
    root.scrollTo({ top, behavior: smooth ? "smooth" : "auto" })
  }

  idOf(link) {
    return decodeURIComponent((link.getAttribute("href") || "").split("#")[1] || "")
  }

  get ids() {
    return this.linkTargets.map(link => this.idOf(link)).filter(Boolean)
  }

  get headings() {
    return this.ids.map(id => document.getElementById(id)).filter(Boolean)
  }

  get root() {
    return this.hasContainerValue && this.containerValue ? document.querySelector(this.containerValue) : null
  }
}
