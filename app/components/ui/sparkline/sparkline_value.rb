# Displays the active point's formatted value, or the final value while idle.
class UI::SparklineValue < UI::Base
  def before_template(&content)
    @render_function = content&.arity&.positive?
    super
  end

  def view_template(&)
    span(**mix({ data: value_data }, @attributes.except(:class)),
         class: cn("text-foreground-intense text-sm font-semibold tabular-nums", override: @attributes[:class])) do
      if @render_function
        sparkline.data.each_index do |index|
          span(hidden: index != last_index, data: { index:, "ui--sparkline-target": "customValue" }) do
            yield sparkline.formatted_values[index], sparkline.data[index]
          end
        end
      else
        plain sparkline.formatted_values.last.to_s
      end
    end
  end

  private
    def sparkline = consume(:ui_sparkline, component: "Sparkline")
    def last_index = sparkline.data.length - 1
    def value_data = { slot: "sparkline-value", "ui--sparkline-target": ("value" unless @render_function) }
end
