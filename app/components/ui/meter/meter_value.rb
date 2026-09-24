# Prints the formatted value ("64%", "$1,280.00"). Customize the text with a block that
# receives the formatted string and the raw value, or map values to words with `labels:`
# (also used for live updates):
#
#   MeterValue { |formatted, _value| "#{formatted} of 8 GB" }
#   MeterValue(labels: %w[ Weak Fair Strong ])
class UI::MeterValue < UI::Base
  def initialize(labels: nil, **attributes)
    @labels = labels
    @attributes = attributes
  end

  def view_template(&block)
    meter = consume(:meter, component: "UI::Meter")
    data = { slot: "meter-value", "ui--meter-target": "value", labels: @labels&.to_json }

    span(**mix({ aria_hidden: "true", data: }, @attributes.except(:class)), class: cn("text-foreground text-sm", override: @attributes[:class])) do
      if block
        block.call(meter.formatted_value, meter.value)
      elsif @labels
        @labels[meter.value.round.clamp(0, @labels.size - 1)]
      else
        meter.formatted_value
      end
    end
  end
end
