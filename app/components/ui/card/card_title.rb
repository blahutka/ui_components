# The headline: an <h3> by default; `as: :h2` (etc.) fits it to the page outline.
class UI::CardTitle < UI::Base
  TAGS = %i[ h1 h2 h3 h4 h5 h6 p div ].freeze

  def initialize(as: :h3, **attributes)
    @tag = TAGS.include?(as.to_sym) ? as.to_sym : :h3
    @attributes = attributes
  end

  def view_template(&)
    send(@tag, **mix({ data: { slot: "card-title" } }, @attributes.except(:class)),
         class: cn("text-foreground-intense text-lg font-semibold", override: @attributes[:class]), &)
  end
end
