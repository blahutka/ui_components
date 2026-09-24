# One suggestion chip (an outline Button at Appica's chip size).
class Blocks::ChatSuggestion < Blocks::Base
  CHIP = "h-6 gap-0.75 rounded-xs px-2 text-xs has-data-[icon=end]:pe-1.5 has-data-[icon=start]:ps-1.5 [&_svg:not([class*='size-'])]:size-3.5"

  param :text

  def view_template(&block)
    Button(**mix({ variant: :outline, size: :sm, data: { slot: "chat-suggestion", text: @text, action: "blocks--chat-assistant#suggest" } }, @attributes.except(:class)),
      class: cn(CHIP, override: @attributes[:class])) do
      block ? yield : plain(@text)
    end
  end
end
