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
# Localized with I18n (`ui_components.revenue_summary.*`, `ui_components.countries.*`): `period:`
# picks the title and the "vs … last month" wording, and money, counts and the change use the
# current locale's number formats (rails-i18n). `title:` / `comparison:` override the wording.
class Blocks::RevenueSummary < Blocks::Base
  CURRENCY_UNITS = { "USD" => "$", "EUR" => "€", "GBP" => "£", "JPY" => "¥", "CZK" => "Kč" }.freeze

  prop :value
  prop :previous,   default: -> { nil }
  prop :period,     ->(value) { value&.to_sym }, default: -> { nil }
  prop :title,      default: -> { nil }
  prop :comparison, default: -> { nil }
  prop :currency,   ->(value) { value.to_s.upcase }, default: -> { "USD" }

  attr_reader :currency

  def money(amount)
    ActiveSupport::NumberHelper.number_to_currency(amount, unit: CURRENCY_UNITS.fetch(@currency, @currency),
      precision: (amount % 1).zero? ? 0 : 2, locale: I18n.locale)
  end

  def number(amount)
    ActiveSupport::NumberHelper.number_to_delimited(amount, locale: I18n.locale)
  end

  # A translation under ui_components.revenue_summary
  def translate(key, **options)
    I18n.t(key, scope: "ui_components.revenue_summary", **options)
  end

  def view_template(&)
    provide(:revenue_summary, self) do
      div(**mix(defaults(data: { slot: "revenue-summary" }), @attributes.except(:class)), class: cn(
        "bg-background border-border-muted flex flex-col rounded-xl border p-6 shadow-lg dark:shadow-[0_8px_16px_-4px_rgba(0,0,0,0.8)]",
        override: @attributes[:class]
      )) do
        div(class: "flex items-center justify-between gap-2") do
          span(class: "text-foreground-muted text-sm") { @title || translate("title.#{period_key}") }
          trend_badge if change
        end
        div(class: "mt-1 flex items-baseline gap-2") do
          span(class: "text-foreground-intense text-3xl font-semibold tabular-nums", data: { slot: "revenue-value" }) { money(@value) }
          span(class: "text-foreground-muted text-xs") { comparison } if @previous
        end
        yield if block_given?
      end
    end
  end

  private
    def period_key
      %i[ day week month year ].include?(@period) ? @period : :other
    end

    def comparison
      translate("comparison", amount: money(@previous), previous: @comparison || translate("previous.#{period_key}"))
    end

    def change
      return if @previous.nil? || @previous.zero?

      (@value - @previous).fdiv(@previous) * 100
    end

    def trend_badge
      up = change >= 0
      percentage = ActiveSupport::NumberHelper.number_to_percentage(change.abs, precision: 1, locale: I18n.locale)

      Badge(variant: (up ? :success : :error), size: :sm, data: { trend: (up ? "up" : "down") }) do
        Icon(up ? :trending_up : :trending_down, data: { icon: "start" })
        span(dir: "ltr") { "#{up ? "+" : "−"}#{percentage}" }
      end
    end
end
