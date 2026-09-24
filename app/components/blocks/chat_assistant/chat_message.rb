# One chat bubble: the user's on the inline-end side, the assistant's on the start side.
class Blocks::ChatMessage < Blocks::Base
  FROM = {
    user: "bg-secondary-soft text-foreground-emphasis rounded-ee-3xs self-end",
    assistant: "bg-background-muted text-foreground rounded-es-3xs self-start"
  }.freeze

  def initialize(from: :assistant, **attributes)
    @from = FROM.key?(from.to_sym) ? from.to_sym : :assistant
    @attributes = attributes
  end

  def view_template(&)
    p(**mix({ data: { slot: "chat-message", from: @from } }, @attributes.except(:class)),
      class: cn("max-w-[85%] rounded-lg px-3.5 py-2 text-sm whitespace-pre-line", FROM[@from], override: @attributes[:class]), &)
  end
end
