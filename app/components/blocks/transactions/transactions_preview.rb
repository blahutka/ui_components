# A recent-transactions card: filter tabs over rows of icon tiles, counterparties, categories,
# dates and signed amounts - composed from Tabs, Thumbnail and Icon.
#
# Localized: switch the toolbar's **Locale** display option and the tabs, dates and amounts follow.
#
# @label Transactions
# @logical_path Blocks
# @component Blocks::Transactions
# @display width wide
class Blocks::TransactionsPreview < UI::BasePreview
  ROWS = [
    { title: "Payroll · Appica Inc.", category: "Income", date: Date.new(2026, 7, 1), amount: 4_150.00, icon: :building_bank },
    { title: "Spotify Premium", category: "Subscription", date: Date.new(2026, 7, 2), amount: -11.99, icon: :brand_spotify },
    { title: "Stripe payout", category: "Income", date: Date.new(2026, 7, 3), amount: 860.40, icon: :brand_stripe },
    { title: "Whole Foods", category: "Groceries", date: Date.new(2026, 7, 4), amount: -74.20, icon: :shopping_cart },
    { title: "Uber", category: "Transport", date: Date.new(2026, 7, 5), amount: -18.40, icon: :car },
    { title: "Card top-up", category: "Transfer", date: Date.new(2026, 7, 5), amount: -200.00, icon: :credit_card }
  ].freeze

  # @label Usage
  # The Appica homepage card. Positive amounts are income; the tabs filter the rows.
  # @param currency [Symbol] select { choices: [USD, EUR, GBP, CZK] }
  # @param filters [Boolean] toggle "Show the filter tabs"
  def default(currency: :USD, filters: true)
    phlex do
      Transactions(currency:, filters:, class: "w-100 max-w-full") do
        ROWS.each { |row| Transaction(**row) }
      end
    end
  end

  # @label Empty filter
  # Only spending here - the Income tab shows the empty message.
  def spending_only
    phlex do
      Transactions(class: "w-100 max-w-full") do
        ROWS.select { |row| row[:amount].negative? }.each { |row| Transaction(**row) }
      end
    end
  end

  # @label RTL
  # Rendered in Arabic whatever the toolbar says.
  def rtl
    phlex do
      I18n.with_locale(:ar) do
        div(dir: "rtl") do
          Transactions(class: "w-100 max-w-full") { ROWS.first(4).each { |row| Transaction(**row) } }
        end
      end
    end
  end
end
