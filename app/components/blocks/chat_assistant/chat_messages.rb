# The scrolling conversation. Its id (the root's `messages_id`) is the Turbo Stream target
# for new messages.
class Blocks::ChatMessages < Blocks::Base
  def initialize(**attributes)
    @attributes = attributes
  end

  def view_template(&)
    chat = consume(:chat_assistant, component: "Blocks::ChatAssistant")

    div(**mix({
      id: chat.messages_id, role: "log", aria_live: "polite", aria_label: "Conversation",
      data: { slot: "chat-messages", "blocks--chat-assistant-target": "messages" }
    }, @attributes.except(:class)), class: cn("mt-4 -me-2 flex min-h-0 flex-1 flex-col gap-3 overflow-y-auto overscroll-contain pe-2 [scrollbar-width:thin]", override: @attributes[:class]), &)
  end
end
