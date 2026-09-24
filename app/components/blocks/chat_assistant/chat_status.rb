# The assistant's "working on it" row with the sparkle spinner. Shown while a reply is pending.
class Blocks::ChatStatus < Blocks::Base
  def initialize(hidden: false, **attributes)
    @hidden = hidden
    @attributes = attributes
  end

  def view_template(&)
    span(**mix({ hidden: @hidden, data: { slot: "chat-status", "blocks--chat-assistant-target": "status" } }, @attributes.except(:class)),
      class: cn("text-foreground-muted inline-flex items-center gap-2 px-1 text-xs", override: @attributes[:class])) do
      Spinner(variant: :sparkle, current_color: true, class: "text-[1.4em]", aria_hidden: "true")
      span(data: { "blocks--chat-assistant-target": "statusText" }, &)
    end
  end
end
