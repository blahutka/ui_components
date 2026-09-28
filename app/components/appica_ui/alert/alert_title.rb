# The headline, an <h5> by default - pick the level that fits the page outline with `as:`.
class AppicaUI::AlertTitle < AppicaUI::Base
  TAGS = %i[ h1 h2 h3 h4 h5 h6 div ].freeze

  prop :as, one_of(TAGS, :h5), as: :tag, default: -> { :h5 }

  def view_template(&)
    send(@tag, **mix({ data: { slot: "alert-title" } }, @attributes.except(:class)), class: cn(
      "text-foreground-intense self-center font-semibold [grid-area:title] text-base",
      "@min-[460px]:group-data-[layout=inline]/alert:me-3 @min-[460px]:group-data-[layout=inline]/alert:text-sm",
      override: @attributes[:class]
    ), &)
  end
end
