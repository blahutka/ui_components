require "test_helper"

class Blocks::RevenueSummaryTest < ComponentTestCase
  test "renders the total, the comparison and an up-trend badge" do
    html = render_ui { RevenueSummary(title: "Monthly revenue", value: 48_210, previous: 42_900, comparison: "last month") }

    assert_equal "$48,210", html.at_css("[data-slot=revenue-value]").text
    assert_includes html.text, "vs $42,900 last month"
    badge = html.at_css("[data-trend]")
    assert_equal "success", badge["data-variant"]
    assert_equal "+12.4%", badge.text.strip
    assert_equal "trending-up", badge.at_css("svg")["data-name"]
  end

  test "a drop turns the badge into a falling error badge; no previous, no badge" do
    down = render_ui { RevenueSummary(value: 9_870, previous: 11_240) }.at_css("[data-trend]")

    assert_equal "error", down["data-variant"]
    assert_equal "−12.2%", down.text.strip
    assert_nil render_ui { RevenueSummary(value: 100) }.at_css("[data-trend]")
  end

  test "markets, chart and stats use the root's currency" do
    html = render_ui do
      RevenueSummary(value: 1_845.5, currency: "EUR") do
        RevenueMarkets do
          RevenueMarket(country: :de, name: "Germany", value: 1_120, share: 61)
          RevenueMarket(country: :fr, name: "France", value: 725.5, share: 39)
        end
        RevenueChart(data: [ 1, 2, 3 ], labels: %w[ a b c ])
        RevenueStats { RevenueStat(label: "Orders") { "12" } }
      end
    end

    assert_equal "€1,845.50", html.at_css("[data-slot=revenue-value]").text
    germany, france = html.css("[data-slot=revenue-market]")
    assert_includes germany.text, "€1,120"
    assert_includes germany.text, "61%"
    assert_equal "de", germany.at_css("svg[data-slot=country-flag]")["data-code"]
    assert_equal "FR", france.at_css("span[data-slot=country-flag]").text.upcase
    assert_includes html.at_css("[data-slot=sparkline]")["data-ui--sparkline-formatted-values-value"], "€3"
    assert_equal "Orders12", html.at_css("[data-slot=revenue-stat]").text
  end

  test "parts outside a RevenueSummary raise" do
    assert_raises(ArgumentError) { render_ui { RevenueMarket(name: "Japan", value: 1) } }
  end
end
