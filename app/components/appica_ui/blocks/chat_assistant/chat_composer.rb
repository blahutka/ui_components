# The message form: a text field with attach, dictate and send buttons. Posts `name:` to the
# root's `action:`; the Stimulus controller shows the message right away and clears the field.
class AppicaUI::Blocks::ChatComposer < AppicaUI::Blocks::Base
  prop :placeholder, default: -> { t(".composer.placeholder") }
  prop :name,        default: -> { "message" }
  prop :label,       default: -> { t(".composer.label") }
  prop :attach,      default: -> { true }
  prop :dictate,     default: -> { true }

  def view_template
    chat = consume(:chat_assistant, component: "AppicaUI::Blocks::ChatAssistant")
    disabled = !chat.online?

    form(action: chat.action || "#", method: chat.method, data: { slot: "chat-composer", action: "appica-ui--blocks--chat-assistant#send" }) do
      div(**mix({ role: "toolbar", aria_label: t(".composer.toolbar"), data: { slot: "toolbar" } }, @attributes.except(:class)),
        class: cn("bg-background mt-3 flex w-full items-center gap-1 rounded-lg border p-1 focus-within:ring-3 focus-within:ring-ring-input", override: @attributes[:class])) do
        input(type: "text", name: @name, placeholder: @placeholder, aria_label: @label, autocomplete: "off", disabled:,
          data: { "appica-ui--blocks--chat-assistant-target": "input", action: "input->appica-ui--blocks--chat-assistant#update" },
          class: "placeholder:text-foreground-subtle h-10 min-w-0 flex-1 bg-transparent ps-3.5 text-sm outline-none disabled:cursor-not-allowed")
        div(role: "group", aria_label: t(".composer.actions"), class: "flex items-center gap-1") do
          Button(variant: :ghost, size: :sm, icon: true, aria_label: t(".composer.attach"), disabled:) { Icon(:paperclip) } if @attach
          Button(variant: :ghost, size: :sm, icon: true, aria_label: t(".composer.dictate"), disabled:) { Icon(:microphone) } if @dictate
          Button(type: "submit", size: :sm, icon: true, aria_label: t(".composer.send"), class: "me-1", disabled: true,
            data: { "appica-ui--blocks--chat-assistant-target": "send" }) { Icon(:send, class: "rtl:-scale-x-100") }
        end
      end
    end
  end
end
