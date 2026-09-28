# Displays the active point's label, or the final label while idle.
class AppicaUI::SparklineLabel < AppicaUI::Base
  def before_template(&content)
    @render_function = content&.arity&.positive?
    super
  end

  def view_template(&)
    return unless sparkline.labels

    span(**mix({ data: label_data }, @attributes.except(:class)),
         class: cn("text-foreground-muted text-xs", override: @attributes[:class])) do
      if @render_function
        sparkline.data.each_index do |index|
          span(hidden: index != last_index, data: { index:, "appica-ui--sparkline-target": "customLabel" }) do
            yield sparkline.labels[index].to_s, sparkline.point(index)
          end
        end
      else
        plain sparkline.labels[last_index].to_s
      end
    end
  end

  private
    def sparkline = consume(:ui_sparkline, component: "Sparkline")
    def last_index = sparkline.data.length - 1
    def label_data = { slot: "sparkline-label", "appica-ui--sparkline-target": ("label" unless @render_function) }
end
