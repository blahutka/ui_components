# A leading icon slot; the icon takes the variant's accent color.
class UI::AlertIcon < UI::Base
  def initialize(**attributes)
    @attributes = attributes
  end

  def view_template(&)
    alert = consume(:alert, component: "UI::Alert")

    span(**mix({ data: { slot: "alert-icon" } }, @attributes.except(:class)),
      class: cn("me-3 flex h-lh shrink-0 items-center [grid-area:icon] [&_svg:not([class*='size-'])]:size-5", alert.icon_class, override: @attributes[:class]), &)
  end
end
