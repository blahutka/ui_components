# The scrolling conversation. Its id (the root's `messages_id`) is the Turbo Stream target
# for new messages.
class AppicaUI::Blocks::ChatMessages < AppicaUI::Blocks::Base
  def view_template(&)
    chat = consume(:chat_assistant, component: "AppicaUI::Blocks::ChatAssistant")

    div(**mix({
      id: chat.messages_id, role: "log", aria_live: "polite", aria_label: t(".conversation"),
      data: { slot: "chat-messages", "appica-ui--blocks--chat-assistant-target": "messages" }
    }, @attributes.except(:class)), class: cn("mt-4 -me-2 flex min-h-0 flex-1 flex-col gap-3 overflow-y-auto overscroll-contain pe-2 [scrollbar-width:thin]", override: @attributes[:class]), &)
  end
end
