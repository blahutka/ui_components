# One market row: flag, name, amount and share of the total.
class Blocks::RevenueMarket < Blocks::Base
  def initialize(name:, value:, share: nil, country: nil, **attributes)
    @name, @value, @share, @country = name, value, share, country
    @attributes = attributes
  end

  def view_template
    summary = consume(:revenue_summary, component: "Blocks::RevenueSummary")

    div(**mix({ data: { slot: "revenue-market" } }, @attributes.except(:class)), class: cn("flex items-center gap-2", override: @attributes[:class])) do
      CountryFlag(@country, class: "size-4") if @country
      span(class: "text-foreground text-xs") { @name }
      span(class: "text-foreground-intense ms-auto text-xs font-medium tabular-nums") { summary.money(@value) }
      span(class: "text-foreground-muted w-8 text-end text-xs tabular-nums") { "#{@share}%" } if @share
    end
  end
end
