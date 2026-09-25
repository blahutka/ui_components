require "test_helper"

class Blocks::TransactionsTest < ComponentTestCase
  test "renders the title, filter tabs and signed rows" do
    html = render_ui do
      Transactions do
        Transaction(title: "Stripe payout", category: "Income", date: Date.new(2026, 7, 3), amount: 860.40, icon: :brand_stripe)
        Transaction(title: "Uber", category: "Transport", date: Date.new(2026, 7, 5), amount: -18.4, icon: :car)
      end
    end

    root = html.at_css("[data-slot=transactions]")
    assert_equal "blocks--transactions", root["data-controller"]
    assert_equal "Recent transactions", root.at_css("h3").text
    assert_equal %w[ All Income Spending ], root.css("[role=tab]").map { |tab| tab.text.strip }

    rows = root.css("li[data-slot=transaction]")
    assert_equal %w[ income spending ], rows.map { |row| row["data-kind"] }
    assert_equal "Income · Jul 3", rows.first.css(".text-xs").text
    assert_equal [ "+$860.40", "-$18.40" ], rows.map { |row| row.at_css("[data-slot=transaction-amount]").text }
    assert_includes rows.first.at_css("[data-slot=transaction-amount]")["class"], "text-success-emphasis"
    assert rows.first.at_css("[data-slot=thumbnail][data-variant=icon_outline] svg")
    assert root.at_css("[data-slot=transactions-empty][hidden]")
  end

  test "dates and amounts follow the locale and filters can be dropped" do
    html = I18n.with_locale(:cs) do
      render_ui do
        Transactions(currency: "EUR", filters: false) { Transaction(title: "Nájem", date: Date.new(2026, 7, 1), amount: -1_250) }
      end
    end

    assert_nil html.at_css("[role=tablist]")
    assert_equal "Poslední transakce", html.at_css("h3").text
    assert_equal "1. 7.", html.at_css("li .text-xs").text
    assert_equal "-1 250,00 €", html.at_css("[data-slot=transaction-amount]").text.gsub(/[[:space:]]/, " ")
  end
end
