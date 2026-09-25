# The trend line under the markets - a Sparkline with a gradient fill that pins itself to the
# bottom of the card. Hover it to read each period (labels + money formatting from the root).
class Blocks::RevenueChart < Blocks::Base
  prop :data
  prop :labels,     default: -> { nil }
  prop :height,     default: -> { 76 }
  prop :aria_label, default: -> { nil }

  def view_template
    summary = consume(:revenue_summary, component: "Blocks::RevenueSummary")

    Sparkline(data: @data, labels: @labels, format: { style: :currency, currency: summary.currency, maximum_fraction_digits: 0 }, locale: I18n.locale,
      **@attributes.except(:class), class: cn("mt-auto pt-3", override: @attributes[:class])) do
      SparklineChart(fill: true, height: @height, tooltip: true, aria_label: @aria_label || summary.translate("chart"))
    end
  end
end
