import { Controller } from "@hotwired/stimulus"

// Behaviour for Blocks::ChatAssistant. Sending shows the user's bubble right away, clears the
// field and shows the status row; the reply arrives as a Turbo Stream append to the messages
// list (the controller notices it, hides the status and keeps the list scrolled to the end).
// In demo mode (no `action:`) it answers by itself from `replies`.
//
// Emits `blocks--chat-assistant:send` with { text } (cancel it to stop the send).
export default class extends Controller {
  static targets = [ "messages", "status", "statusText", "input", "send", "suggestions", "userTemplate", "assistantTemplate" ]
  static values = { demo: Boolean, replies: Array }

  connect() {
    this.replyIndex = 0
    this.observer = new MutationObserver(records => this.messagesChanged(records))
    if (this.hasMessagesTarget) this.observer.observe(this.messagesTarget, { childList: true })
    this.update()
    this.scrollToEnd()

    // The demo finishes a reply that was already "in progress" when the page rendered
    if (this.demoValue && this.pending) this.demoReply()
  }

  disconnect() {
    this.observer?.disconnect()
    clearTimeout(this.replyTimer)
  }

  update() {
    if (this.hasSendTarget) this.sendTarget.disabled = !this.hasInputTarget || this.inputTarget.disabled || !this.inputTarget.value.trim()
  }

  suggest({ currentTarget }) {
    if (!this.hasInputTarget || this.inputTarget.disabled) return

    this.inputTarget.value = currentTarget.dataset.text
    this.update()
    this.inputTarget.form.requestSubmit()
  }

  send(event) {
    const text = this.inputTarget.value.trim()
    if (!text) return event.preventDefault()

    const sent = this.dispatch("send", { detail: { text }, cancelable: true })
    if (sent.defaultPrevented) return event.preventDefault()

    this.append("user", text)
    this.showStatus()

    if (this.demoValue) {
      event.preventDefault()
      this.clear()
      this.demoReply()
    } else {
      // Turbo reads the form data after this handler - clear the field once it has
      setTimeout(() => this.clear())
    }
  }

  // A reply appended by Turbo Streams (or anything else) ends the pending state
  messagesChanged(records) {
    const replied = records.some(record => [ ...record.addedNodes ].some(node =>
      node.nodeType === 1 && node.dataset.from === "assistant" && !node.dataset.local))
    if (replied) this.hideStatus()
    this.scrollToEnd()
  }

  append(from, text) {
    const template = from === "user" ? this.userTemplateTarget : this.assistantTemplateTarget
    const message = template.content.firstElementChild.cloneNode(true)
    message.textContent = text
    message.dataset.local = ""
    this.hasStatusTarget ? this.messagesTarget.insertBefore(message, this.statusTarget) : this.messagesTarget.append(message)
    this.scrollToEnd()
  }

  demoReply() {
    clearTimeout(this.replyTimer)
    this.replyTimer = setTimeout(() => {
      const replies = this.repliesValue.length ? this.repliesValue : [ "Done - have a look at the preview." ]
      this.append("assistant", replies[this.replyIndex++ % replies.length])
      this.hideStatus()
    }, 1600)
  }

  showStatus() {
    if (!this.hasStatusTarget) return

    this.messagesTarget.append(this.statusTarget)
    if (this.hasStatusTextTarget && !this.statusTextTarget.textContent.trim()) this.statusTextTarget.textContent = "Thinking…"
    this.statusTarget.hidden = false
    this.scrollToEnd()
  }

  hideStatus() {
    if (this.hasStatusTarget) this.statusTarget.hidden = true
  }

  clear() {
    this.inputTarget.value = ""
    this.update()
  }

  scrollToEnd() {
    if (this.hasMessagesTarget) this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  get pending() {
    return this.hasStatusTarget && !this.statusTarget.hidden
  }
}
