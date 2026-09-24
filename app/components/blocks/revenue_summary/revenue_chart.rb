# The trend line under the markets - a Sparkline with a gradient fill that pins itself to the
# bottom of the card. Hover it to read each period (labels + money formatting from the root).
class Blocks::RevenueChart < Blocks::Base
  def initialize(data:, labels: nil, height: 76, aria_label: "Revenue trend", **attributes)
    @data, @labels, @height, @aria_label = data, labels, height, aria_label
    @attributes = attributes
  end

  def view_template
    summary = consume(:revenue_summary, component: "Blocks::RevenueSummary")

    Sparkline(data: @data, labels: @labels, format: { style: :currency, currency: summary.currency, maximum_fraction_digits: 0 },
      **@attributes.except(:class), class: cn("mt-auto pt-3", override: @attributes[:class])) do
      SparklineChart(fill: true, height: @height, tooltip: true, aria_label: @aria_label)
    end
  end
end
