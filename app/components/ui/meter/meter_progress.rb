# The track and its fill; the fill's color comes from the root's status.
class UI::MeterProgress < UI::Base
  def view_template
    meter = consume(:meter, component: "UI::Meter")

    div(**mix({ data: { slot: "meter-progress" } }, @attributes.except(:class)),
      class: cn("bg-background-strong relative h-1.5 w-full overflow-hidden rounded-full", override: @attributes[:class])) do
      div(
        data: { slot: "meter-indicator", "ui--meter-target": "indicator" },
        style: "inset-inline-start: 0; height: inherit; width: #{meter.percentage.round(4)}%",
        class: cn("rounded-full transition-[width,background-color] duration-300 motion-reduce:transition-none", meter.indicator_class)
      )
    end
  end
end
