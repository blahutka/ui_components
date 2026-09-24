# The message form: a text field with attach, dictate and send buttons. Posts `name:` to the
# root's `action:`; the Stimulus controller shows the message right away and clears the field.
class Blocks::ChatComposer < Blocks::Base
  prop :placeholder, default: -> { "Ask anything…" }
  prop :name,        default: -> { "message" }
  prop :label,       default: -> { "Message the assistant" }
  prop :attach,      default: -> { true }
  prop :dictate,     default: -> { true }

  def view_template
    chat = consume(:chat_assistant, component: "Blocks::ChatAssistant")
    disabled = !chat.online?

    form(action: chat.action || "#", method: chat.method, data: { slot: "chat-composer", action: "blocks--chat-assistant#send" }) do
      div(**mix({ role: "toolbar", aria_label: "Message composer", data: { slot: "toolbar" } }, @attributes.except(:class)),
        class: cn("bg-background mt-3 flex w-full items-center gap-1 rounded-lg border p-1 focus-within:ring-3 focus-within:ring-ring-input", override: @attributes[:class])) do
        input(type: "text", name: @name, placeholder: @placeholder, aria_label: @label, autocomplete: "off", disabled:,
          data: { "blocks--chat-assistant-target": "input", action: "input->blocks--chat-assistant#update" },
          class: "placeholder:text-foreground-subtle h-10 min-w-0 flex-1 bg-transparent ps-3.5 text-sm outline-none disabled:cursor-not-allowed")
        div(role: "group", aria_label: "Composer actions", class: "flex items-center gap-1") do
          Button(variant: :ghost, size: :sm, icon: true, aria_label: "Attach files", disabled:) { Icon(:paperclip) } if @attach
          Button(variant: :ghost, size: :sm, icon: true, aria_label: "Dictate a message", disabled:) { Icon(:microphone) } if @dictate
          Button(type: "submit", size: :sm, icon: true, aria_label: "Send message", class: "me-1", disabled: true,
            data: { "blocks--chat-assistant-target": "send" }) { Icon(:send, class: "rtl:-scale-x-100") }
        end
      end
    end
  end
end
