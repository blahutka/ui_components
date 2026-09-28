import DropdownMenuController from "appica_ui/dropdown_menu/dropdown_menu_controller"

// AppicaUI::ContextMenu: DropdownMenu's menu, opened at the pointer by right-click, a long press on
// touch (500 ms) or Shift+F10 / the context-menu key on the focused area. Focus returns to
// where it was when the menu closes.
const LONG_PRESS = 500

export default class extends DropdownMenuController {
  openAtPointer(event) {
    event.preventDefault()
    this.openAt(event.clientX, event.clientY)
  }

  openAt(x, y) {
    this.returnFocus = document.activeElement
    if (this.isOpen) this.close({ instant: true })
    this.open({ anchor: { left: x, top: y, right: x, bottom: y }, focus: "content" })
  }

  // Long press on touch
  press(event) {
    if (event.pointerType !== "touch") return
    this.pressStart = { x: event.clientX, y: event.clientY }
    this.pressTimer = setTimeout(() => this.openAt(event.clientX, event.clientY), LONG_PRESS)
  }

  pressMove(event) {
    if (!this.pressStart) return
    if (Math.hypot(event.clientX - this.pressStart.x, event.clientY - this.pressStart.y) > 10) this.release()
  }

  release() {
    clearTimeout(this.pressTimer)
    this.pressStart = null
  }

  key(event) {
    if (this.hasTriggerTarget && this.triggerTarget.contains(event.target) && !event.target.closest("[role=menu]")) {
      if (event.key === "ContextMenu" || (event.key === "F10" && event.shiftKey)) {
        event.preventDefault()
        const rect = event.target.getBoundingClientRect()
        this.openAt(rect.left + rect.width / 2, rect.top + rect.height / 2)
        this.itemsIn(this.contentTarget)[0]?.focus()
      }
      return
    }
    super.key(event)
  }

  toggle() {}

  close(options = {}) {
    const wasOpen = this.isOpen
    super.close({ ...options, focusTrigger: false })
    if (wasOpen && options.focusTrigger) this.returnFocus?.focus?.({ preventScroll: true })
  }
}
