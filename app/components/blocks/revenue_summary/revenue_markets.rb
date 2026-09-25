# The "Top markets" list.
class Blocks::RevenueMarkets < Blocks::Base
  prop :title, default: -> { nil }

  def view_template(&)
    summary = consume(:revenue_summary, component: "Blocks::RevenueSummary")

    div(**mix({ data: { slot: "revenue-markets" } }, @attributes.except(:class)), class: cn("mt-4 flex flex-col gap-2.5", override: @attributes[:class])) do
      span(class: "text-foreground-muted text-xs") { @title || summary.translate("markets") }
      yield
    end
  end
end
