# The headline: an <h3> by default; `as: :h2` (etc.) fits it to the page outline.
class AppicaUI::CardTitle < AppicaUI::Base
  TAGS = %i[ h1 h2 h3 h4 h5 h6 p div ].freeze

  prop :as, one_of(TAGS, :h3), as: :tag, default: -> { :h3 }

  def view_template(&)
    send(@tag, **mix({ data: { slot: "card-title" } }, @attributes.except(:class)),
         class: cn("text-foreground-intense text-lg font-semibold", override: @attributes[:class]), &)
  end
end
