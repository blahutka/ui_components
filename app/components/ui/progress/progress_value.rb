# Prints the formatted value ("60%"). A block receives the formatted string and the raw value:
#
#   ProgressValue { |formatted, _value| "#{formatted} done" }
class UI::ProgressValue < UI::Base
  def initialize(**attributes)
    @attributes = attributes
  end

  def view_template(&block)
    progress = consume(:progress, component: "UI::Progress")

    span(**mix({ aria_hidden: "true", data: { slot: "progress-value", progress.state => "", "ui--progress-target": "value" } }, @attributes.except(:class)),
      class: cn("text-foreground text-sm", override: @attributes[:class])) do
      block ? block.call(progress.formatted_value, progress.value) : progress.formatted_value
    end
  end
end
