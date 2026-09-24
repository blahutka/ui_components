# Names the meter; the root points aria-labelledby at it.
class UI::MeterLabel < UI::Base
  def initialize(**attributes)
    @attributes = attributes
  end

  def view_template(&)
    meter = consume(:meter, component: "UI::Meter")

    span(**mix({ id: meter.label_id, data: { slot: "meter-label" } }, @attributes.except(:class)),
      class: cn("text-foreground-intense text-sm font-medium", override: @attributes[:class]), &)
  end
end
