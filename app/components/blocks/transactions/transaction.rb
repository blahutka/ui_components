# One Transactions row: an icon tile, the counterparty, its category and date, and the signed
# amount (income in the success color).
#
#   Transaction(title: "Stripe payout", category: "Income", date: Date.new(2026, 7, 3), amount: 860.40, icon: :brand_stripe)
class Blocks::Transaction < Blocks::Base
  prop :title
  prop :amount
  prop :category, default: -> { nil }
  prop :date,     default: -> { nil }
  prop :icon,     default: -> { :receipt }

  def view_template
    root = consume(:transactions, component: "Blocks::Transactions")

    li(**mix({ data: { slot: "transaction", kind:, "blocks--transactions-target": "row" } }, @attributes.except(:class)),
      class: cn("border-border flex items-center gap-3 border-t border-dashed py-2.75 first:border-t-0 data-first:border-t-0", override: @attributes[:class])) do
      Thumbnail(variant: :icon_outline, size: :sm) { Icon(@icon) }
      div(class: "min-w-0 flex-1") do
        div(class: "text-foreground-intense truncate text-sm font-medium") { @title }
        div(class: "text-foreground-muted truncate text-xs") { meta } if @category || @date
      end
      span(class: "#{income? ? "text-success-emphasis" : "text-foreground-intense"} text-sm font-medium tabular-nums whitespace-nowrap",
        data: { slot: "transaction-amount" }) do
        "#{income? ? "+" : "-"}#{format_money(@amount.to_d.abs, currency: root.currency, precision: 2)}"
      end
    end
  end

  private
    def income? = !@amount.negative?

    def kind = income? ? "income" : "spending"

    def meta
      [ @category, (I18n.l(@date.to_date, format: t("ui_components.blocks.transactions.date_format")) if @date) ].compact.join(" · ")
    end
end
