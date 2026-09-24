// The toast manager (Appica's useToastManager), available as `UI.toast` or
// `import { toast } from "ui/toast/toast"`. It sends window events that the page's Toaster
// (the `ui--toaster` controller) turns into toasts.
//
//   const id = toast.add({ title: "Changes saved", description: "…", icon: "success" })
//   toast.update(id, { title: "Saved" })
//   toast.close(id)
//   toast.promise(fetch(url), { loading: { title: "Saving…" }, success: { title: "Saved" }, error: { title: "Failed" } })
//
// Options: title, description, icon ("success" | "error" | "warning" | "info" | "loading" | "bell"),
// thumbnail, timeout (ms, 0 = sticky), type, priority ("low" | "high"), dismissible,
// position ("top-left" … "bottom-right"), action { label, onClick, toast }, onClose.
let counter = 0

const emit = (name, detail) => window.dispatchEvent(new CustomEvent(`ui--toast:${name}`, { detail }))

export const toast = {
  add(options = {}) {
    const id = options.id || `toast-${Date.now().toString(36)}-${++counter}`
    emit("add", { ...options, id })
    return id
  },

  update(id, options = {}) {
    emit("update", { id, options })
  },

  close(id) {
    emit("close", { id })
  },

  // Show `loading` until the promise settles, then swap to `success` or `error`
  // (objects, or functions receiving the value / error)
  async promise(promise, { loading, success, error } = {}) {
    const id = this.add({ timeout: 0, ...loading })
    const resolve = (state, value) => (typeof state === "function" ? state(value) : state) || {}

    try {
      const value = await promise
      this.update(id, { timeout: null, ...resolve(success, value) })
      return value
    } catch (reason) {
      this.update(id, { timeout: null, ...resolve(error, reason) })
      throw reason
    }
  }
}

window.UI = window.UI || {}
window.UI.toast = toast

export default toast
