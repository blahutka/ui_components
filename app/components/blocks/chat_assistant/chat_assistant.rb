# An assistant chat card: a header, the conversation, a "thinking" status, suggestion chips and
# a composer - the Appica homepage's assistant, composed from UI primitives.
#
#   ChatAssistant(title: "Appica Assistant", action: chat_messages_path) do
#     ChatHeader()
#     ChatMessages do
#       ChatMessage(from: :user) { "Make the Pro tier featured." }
#       ChatStatus { "Generating preview" }
#     end
#     ChatSuggestions([ "Add a FAQ section", "Use dark theme" ])
#     ChatComposer(placeholder: "Ask anything…")
#   end
#
# The composer is a real form posting `message` to `action:` (Turbo submits it); answer with
# `turbo_stream.append messages_id, Blocks::ChatMessage.new(from: :assistant) { … }`.
# Without an `action:` it runs a demo that replies with `demo_replies:` - handy in previews.
class Blocks::ChatAssistant < Blocks::Base
  attr_reader :title, :action, :method, :messages_id

  def initialize(title: "Assistant", action: nil, method: :post, status: :online, messages_id: nil, demo_replies: [], **attributes)
    @title = title
    @action, @method = action, method
    @status = status.to_sym
    @demo_replies = demo_replies
    @attributes = attributes
    @messages_id = messages_id || "chat-messages-#{SecureRandom.hex(4)}"
  end

  def online?
    @status == :online
  end

  def view_template(&)
    provide(:chat_assistant, self) do
      div(**mix(defaults(data: root_data), @attributes.except(:class)), class: cn(
        "bg-background border-border-muted flex flex-col rounded-xl border p-6 shadow-lg dark:shadow-[0_8px_16px_-4px_rgba(0,0,0,0.8)]",
        override: @attributes[:class]
      )) do
        yield if block_given?
        template(data: { "blocks--chat-assistant-target": "userTemplate" }) { ChatMessage(from: :user) }
        template(data: { "blocks--chat-assistant-target": "assistantTemplate" }) { ChatMessage(from: :assistant) }
      end
    end
  end

  private
    def root_data
      {
        slot: "chat-assistant", status: @status, controller: "blocks--chat-assistant",
        "blocks--chat-assistant-demo-value": @action.nil?.to_s,
        "blocks--chat-assistant-replies-value": @demo_replies.to_json
      }
    end
end
