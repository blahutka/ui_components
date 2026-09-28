# Names the meter; the root points aria-labelledby at it.
class AppicaUI::MeterLabel < AppicaUI::Base
  def view_template(&)
    meter = consume(:meter, component: "AppicaUI::Meter")

    span(**mix({ id: meter.label_id, data: { slot: "meter-label" } }, @attributes.except(:class)),
      class: cn("text-foreground-intense text-sm font-medium", override: @attributes[:class]), &)
  end
end
