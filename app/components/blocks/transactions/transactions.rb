# A recent-transactions card: a title, All / Income / Spending filter tabs and a list of
# Transaction rows - composed from Tabs, Thumbnail and Icon.
#
#   Transactions(currency: "USD") do
#     account.transactions.recent.each do |transaction|
#       Transaction(title: transaction.counterparty, category: transaction.category, date: transaction.booked_on,
#         amount: transaction.amount, icon: :building_bank)
#     end
#   end
#
# A positive amount is income, a negative one spending; the tabs filter the rows in the browser
# (`blocks--transactions`). `filters: false` drops the tabs. Strings: transactions.locales.yml.
class Blocks::Transactions < Blocks::Base
  FILTERS = %w[ all income spending ].freeze

  prop :title,    default: -> { t(".title") }
  prop :currency, default: -> { "USD" }
  prop :filters,  default: -> { true }

  attr_reader :currency

  def view_template(&)
    provide(:transactions, self) do
      div(**mix(defaults(data: { slot: "transactions", controller: "blocks--transactions", action: "ui--tabs:change->blocks--transactions#filter" }),
        @attributes.except(:class)), class: cn(
          "bg-background border-border-muted flex flex-col rounded-xl border p-6 shadow-lg dark:shadow-[0_8px_16px_-4px_rgba(0,0,0,0.8)]",
          override: @attributes[:class]
        )) do
        h3(class: "text-foreground-intense text-sm font-semibold") { @title }
        filters if @filters
        ul(class: "mt-2 flex flex-1 flex-col", aria_label: @title, data: { slot: "transactions-list" }, &)
        p(hidden: true, class: "text-foreground-muted py-6 text-center text-sm", data: { slot: "transactions-empty", "blocks--transactions-target": "empty" }) { t(".empty") }
      end
    end
  end

  private
    def filters
      Tabs(default_value: "all", size: :sm, class: "mt-3") do
        TabsList(aria_label: t(".filter")) do
          FILTERS.each { |kind| TabsTrigger(value: kind) { t(".#{kind}") } }
        end
      end
    end
end
