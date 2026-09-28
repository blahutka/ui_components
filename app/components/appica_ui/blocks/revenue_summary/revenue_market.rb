# One market row: flag, country name, amount and share of the total.
class AppicaUI::Blocks::RevenueMarket < AppicaUI::Blocks::Base
  prop :country, default: -> { nil }
  prop :value
  prop :share,   default: -> { nil }
  prop :name,    default: -> { @country && t("ui_components.countries.#{@country}", default: @country.to_s.upcase) }

  def view_template
    summary = consume(:revenue_summary, component: "AppicaUI::Blocks::RevenueSummary")

    div(**mix({ data: { slot: "revenue-market" } }, @attributes.except(:class)), class: cn("flex items-center gap-2", override: @attributes[:class])) do
      CountryFlag(@country, class: "size-4") if @country
      span(class: "text-foreground text-xs") { @name }
      span(class: "text-foreground-intense ms-auto text-xs font-medium tabular-nums") { summary.money(@value) }
      span(class: "text-foreground-muted w-8 text-end text-xs tabular-nums") { format_percent(@share) } if @share
    end
  end
end
