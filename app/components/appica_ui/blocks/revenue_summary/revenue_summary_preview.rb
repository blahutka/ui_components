# A revenue overview card: the period's total with a trend badge, top markets, a trend chart
# and key stats - composed from Badge, Icon and Sparkline.
#
# Localized: switch the toolbar's **Locale** display option (English, Čeština, Deutsch,
# العربية) and the wording, country names, month labels and number formats follow.
#
# @label Revenue summary
# @logical_path Blocks
# @component AppicaUI::Blocks::RevenueSummary
# @display width wide
class AppicaUI::Blocks::RevenueSummaryPreview < AppicaUI::BasePreview
  # Props not in the Usage form (data, render blocks, generated ids): see ui_components:preview_params
  UNLISTED_PROPS = %i[ title comparison ].freeze

  REVENUE = [ 33_900, 32_100, 36_800, 35_700, 32_800, 39_200, 44_700, 42_700, 40_200, 40_900, 43_600, 48_210 ].freeze

  # @label Usage
  # The Appica homepage card. The badge compares `value:` with `previous:`; hover the chart to
  # read each month.
  # @param value number
  # @param previous number
  # @param period [Symbol] select { choices: [day, week, month, year] }
  # @param currency [Symbol] select {{ CURRENCIES }}
  def default(value: 48_210, previous: 42_900, period: :month, currency: :USD)
    phlex do
      RevenueSummary(period:, value: value.to_f, previous: previous.to_f, currency: currency.to_s, class: "w-100 max-w-full") do
        RevenueMarkets do
          RevenueMarket(country: :us, value: 21_690, share: 45)
          RevenueMarket(country: :de, value: 9_640, share: 20)
          RevenueMarket(country: :jp, value: 7_230, share: 15)
        end
        RevenueChart(data: REVENUE[0...-1] + [ value.to_f ], labels: I18n.t("date.abbr_month_names").compact)
        RevenueStats do
          RevenueStat(label: :orders, value: 1_208)
          RevenueStat(label: :average_order, value: 39.9, money: true)
        end
      end
    end
  end

  # @label Down on last period
  # A drop flips the badge to the error color and a falling arrow.
  def decline
    phlex do
      RevenueSummary(value: 9_870, previous: 11_240, period: :week, class: "w-100 max-w-full") do
        RevenueChart(data: [ 11_240, 10_900, 11_600, 10_300, 9_800, 10_100, 9_870 ], labels: I18n.t("date.abbr_day_names").rotate)
        RevenueStats do
          RevenueStat(label: :orders, value: 312)
          RevenueStat(label: :refunds, value: 14)
          RevenueStat(label: :conversion) { ActiveSupport::NumberHelper.number_to_percentage(2.8, precision: 1, locale: I18n.locale) }
        end
      end
    end
  end

  # @label Compact
  # Every part is optional: just the total and the markets. Countries without a bundled flag
  # show their code on a tile.
  def compact
    phlex do
      RevenueSummary(value: 1_845.5, period: :day, currency: "EUR", class: "w-80 max-w-full") do
        RevenueMarkets do
          RevenueMarket(country: :de, value: 1_120, share: 61)
          RevenueMarket(country: :fr, value: 725.5, share: 39)
        end
      end
    end
  end

  # @label Custom wording
  # `title:`, `comparison:`, market `name:` and stat labels take plain strings when the built-in
  # translations don't fit.
  def custom_wording
    phlex do
      RevenueSummary(value: 48_210, previous: 42_900, title: "Store revenue · EU", comparison: "the same month last year", class: "w-100 max-w-full") do
        RevenueMarkets(title: "Best-selling regions") do
          RevenueMarket(country: :de, name: "DACH", value: 21_690, share: 45)
        end
        RevenueStats { RevenueStat(label: "New customers", value: 342) }
      end
    end
  end

  # @label RTL
  # Rendered in Arabic whatever the toolbar says: amounts and shares align to the inline end,
  # and the chart runs in the reading direction.
  def rtl
    phlex do
      I18n.with_locale(:ar) do
        div(dir: "rtl") do
          RevenueSummary(value: 48_210, previous: 42_900, period: :month, class: "w-100 max-w-full") do
            RevenueMarkets do
              RevenueMarket(country: :us, value: 21_690, share: 45)
              RevenueMarket(country: :de, value: 9_640, share: 20)
            end
            RevenueChart(data: REVENUE, labels: I18n.t("date.abbr_month_names").compact)
            RevenueStats do
              RevenueStat(label: :orders, value: 1_208)
              RevenueStat(label: :average_order, value: 39.9, money: true)
            end
          end
        end
      end
    end
  end
end
