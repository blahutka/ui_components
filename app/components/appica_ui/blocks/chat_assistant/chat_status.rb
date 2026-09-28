# The assistant's "working on it" row with the sparkle spinner. Shown while a reply is pending.
class AppicaUI::Blocks::ChatStatus < AppicaUI::Blocks::Base
  prop :hidden, default: -> { false }

  def view_template(&block)
    span(**mix({ hidden: @hidden, data: { slot: "chat-status", "appica-ui--blocks--chat-assistant-target": "status" } }, @attributes.except(:class)),
      class: cn("text-foreground-muted inline-flex items-center gap-2 px-1 text-xs", override: @attributes[:class])) do
      Spinner(variant: :sparkle, current_color: true, class: "text-[1.4em]", aria_hidden: "true")
      span(data: { "appica-ui--blocks--chat-assistant-target": "statusText" }) { block ? yield : t(".thinking") }
    end
  end
end
