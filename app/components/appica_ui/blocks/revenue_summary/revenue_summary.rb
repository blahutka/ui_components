# A revenue overview card: the period's total with a trend badge against the previous period,
# top markets, a trend chart and a row of key stats - composed from Badge, Icon and Sparkline.
#
#   RevenueSummary(value: 48_210, previous: 42_900, period: :month) do
#     RevenueMarkets do
#       RevenueMarket(country: :us, value: 21_690, share: 45)
#     end
#     RevenueChart(data: monthly_totals, labels: month_names)
#     RevenueStats do
#       RevenueStat(label: :orders, value: 1_208)
#       RevenueStat(label: :average_order, value: 39.9, money: true)
#     end
#   end
#
# Localized: the strings are in revenue_summary.locales.yml next to this file (t(".key") in any
# part), country names in ui/countries.locales.yml. `period:` picks the title and the
# "vs … last month" wording; `title:` / `comparison:` override them. Money, counts and the change
# use the current locale's number formats (rails-i18n).
class AppicaUI::Blocks::RevenueSummary < AppicaUI::Blocks::Base
  PERIODS = %i[ day week month year ].freeze

  prop :value
  prop :previous,   default: -> { nil }
  prop :period,     ->(value) { PERIODS.include?(value&.to_sym) ? value.to_sym : :other }, default: -> { :other }
  prop :title,      default: -> { t(".title.#{@period}") }
  prop :comparison, default: -> { t(".previous.#{@period}") }
  prop :currency,   ->(value) { value.to_s.upcase }, default: -> { "USD" }

  attr_reader :currency

  # Amounts in the card's currency and the current locale - parts use it through the context
  def money(amount)
    format_money(amount, currency: @currency)
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
          span(class: "text-foreground-muted text-xs") { t(".comparison", amount: money(@previous), previous: @comparison) } if @previous
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
        span(dir: "ltr") { format_percent(change, precision: 1, sign: true) }
      end
    end
end
