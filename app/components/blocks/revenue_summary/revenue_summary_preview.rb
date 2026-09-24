# A revenue overview card: the period's total with a trend badge, top markets, a trend chart
# and key stats - composed from Badge, Icon and Sparkline.
#
# @label Revenue summary
# @logical_path Blocks
# @component Blocks::RevenueSummary
# @display width wide
class Blocks::RevenueSummaryPreview < UI::BasePreview
  MONTHS = %w[ Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ].freeze
  REVENUE = [ 33_900, 32_100, 36_800, 35_700, 32_800, 39_200, 44_700, 42_700, 40_200, 40_900, 43_600, 48_210 ].freeze

  # @label Usage
  # The Appica homepage card. The badge compares `value:` with `previous:`; hover the chart to
  # read each month.
  # @param value number
  # @param previous number
  # @param currency [Symbol] select { choices: [USD, EUR, GBP] }
  def default(value: 48_210, previous: 42_900, currency: :USD)
    phlex do
      RevenueSummary(title: "Monthly revenue", value: value.to_f, previous: previous.to_f, comparison: "last month", currency: currency.to_s, class: "w-100 max-w-full") do
        RevenueMarkets do
          RevenueMarket(country: :us, name: "United States", value: 21_690, share: 45)
          RevenueMarket(country: :de, name: "Germany", value: 9_640, share: 20)
          RevenueMarket(country: :jp, name: "Japan", value: 7_230, share: 15)
        end
        RevenueChart(data: REVENUE[0...-1] + [ value.to_f ], labels: MONTHS, aria_label: "Revenue over the last 12 months")
        RevenueStats do
          RevenueStat(label: "Orders") { "1,208" }
          RevenueStat(label: "Avg. order value") { "$39.90" }
        end
      end
    end
  end

  # @label Down on last period
  # A drop flips the badge to the error color and a falling arrow.
  def decline
    phlex do
      RevenueSummary(title: "Weekly revenue", value: 9_870, previous: 11_240, comparison: "last week", class: "w-100 max-w-full") do
        RevenueChart(data: [ 11_240, 10_900, 11_600, 10_300, 9_800, 10_100, 9_870 ], labels: %w[ Mon Tue Wed Thu Fri Sat Sun ], aria_label: "Revenue this week")
        RevenueStats do
          RevenueStat(label: "Orders") { "312" }
          RevenueStat(label: "Refunds") { "14" }
          RevenueStat(label: "Conversion") { "2.8%" }
        end
      end
    end
  end

  # @label Compact
  # Every part is optional: just the total and the markets.
  def compact
    phlex do
      RevenueSummary(title: "Revenue today", value: 1_845.5, currency: "EUR", class: "w-80 max-w-full") do
        RevenueMarkets(title: "By country") do
          RevenueMarket(country: :de, name: "Germany", value: 1_120, share: 61)
          RevenueMarket(country: :fr, name: "France", value: 725.5, share: 39)
        end
      end
    end
  end

  # @label RTL
  # Amounts and shares align to the inline end, and the chart (like Sparkline) runs in the
  # reading direction; the trend figure stays "+12.4%".
  def rtl
    phlex do
      div(dir: "rtl") do
        RevenueSummary(title: "الإيرادات الشهرية", value: 48_210, previous: 42_900, comparison: "الشهر الماضي", class: "w-100 max-w-full") do
          RevenueMarkets(title: "أهم الأسواق") do
            RevenueMarket(country: :us, name: "الولايات المتحدة", value: 21_690, share: 45)
            RevenueMarket(country: :de, name: "ألمانيا", value: 9_640, share: 20)
          end
          RevenueChart(data: REVENUE, aria_label: "الإيرادات خلال 12 شهرًا")
          RevenueStats do
            RevenueStat(label: "الطلبات") { "1,208" }
            RevenueStat(label: "متوسط قيمة الطلب") { "$39.90" }
          end
        end
      end
    end
  end
end
