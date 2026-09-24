# A revenue overview card: the period's total with a trend badge against the previous period,
# top markets, a trend chart and a row of key stats - composed from Badge, Icon and Sparkline.
#
#   RevenueSummary(title: "Monthly revenue", value: 48_210, previous: 42_900, comparison: "last month") do
#     RevenueMarkets do
#       RevenueMarket(country: :us, name: "United States", value: 21_690, share: 45)
#     end
#     RevenueChart(data: monthly_totals, labels: month_names)
#     RevenueStats do
#       RevenueStat(label: "Orders") { "1,208" }
#     end
#   end
#
# Money is formatted with `currency:` (Intl-style options via UI::NumberFormat).
class Blocks::RevenueSummary < Blocks::Base
  include UI::NumberFormat

  attr_reader :currency

  def initialize(value:, title: "Revenue", previous: nil, comparison: "last period", currency: "USD", **attributes)
    @value, @previous = value, previous
    @title, @comparison = title, comparison
    @currency = currency
    @attributes = attributes
  end

  def money(amount)
    format_number(amount, style: :currency, currency: @currency, maximum_fraction_digits: (amount % 1).zero? ? 0 : 2)
  end

  def view_template(&)
    provide(:revenue_summary, self) do
      div(**mix(defaults(data: { slot: "revenue-summary" }), @attributes.except(:class)), class: cn(
        "bg-background border-border-muted flex flex-col rounded-xl border p-6 shadow-lg dark:shadow-[0_8px_16px_-4px_rgba(0,0,0,0.8)]",
        override: @attributes[:class]
      )) do
        div(class: "flex items-center justify-between gap-2") do
          span(class: "text-foreground-muted text-sm") { @title }
          trend_badge if change
        end
        div(class: "mt-1 flex items-baseline gap-2") do
          span(class: "text-foreground-intense text-3xl font-semibold tabular-nums", data: { slot: "revenue-value" }) { money(@value) }
          span(class: "text-foreground-muted text-xs") { "vs #{money(@previous)} #{@comparison}" } if @previous
        end
        yield if block_given?
      end
    end
  end

  private
    def change
      return if @previous.nil? || @previous.zero?

      (@value - @previous).fdiv(@previous) * 100
    end

    def trend_badge
      up = change >= 0
      Badge(variant: (up ? :success : :error), size: :sm, data: { trend: (up ? "up" : "down") }) do
        Icon(up ? :trending_up : :trending_down, data: { icon: "start" })
        span(dir: "ltr") { "#{up ? "+" : "−"}#{change.abs.round(1)}%" }
      end
    end
end
