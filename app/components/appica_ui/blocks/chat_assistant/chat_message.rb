# One chat bubble: the user's on the inline-end side, the assistant's on the start side.
class AppicaUI::Blocks::ChatMessage < AppicaUI::Blocks::Base
  FROM = {
    user: "bg-secondary-soft text-foreground-emphasis rounded-ee-3xs self-end",
    assistant: "bg-background-muted text-foreground rounded-es-3xs self-start"
  }.freeze

  prop :from, ->(value) { FROM.key?(value.to_sym) ? value.to_sym : :assistant }, default: -> { :assistant }

  def view_template(&)
    p(**mix({ data: { slot: "chat-message", from: @from } }, @attributes.except(:class)),
      class: cn("max-w-[85%] rounded-lg px-3.5 py-2 text-sm whitespace-pre-line", FROM[@from], override: @attributes[:class]), &)
  end
end
