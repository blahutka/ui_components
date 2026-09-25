# One market row: flag, name, amount and share of the total.
class Blocks::RevenueMarket < Blocks::Base
  prop :value
  prop :name,    default: -> { nil }
  prop :share,   default: -> { nil }
  prop :country, default: -> { nil }

  def view_template
    summary = consume(:revenue_summary, component: "Blocks::RevenueSummary")

    div(**mix({ data: { slot: "revenue-market" } }, @attributes.except(:class)), class: cn("flex items-center gap-2", override: @attributes[:class])) do
      CountryFlag(@country, class: "size-4") if @country
      span(class: "text-foreground text-xs") { @name || country_name }
      span(class: "text-foreground-intense ms-auto text-xs font-medium tabular-nums") { summary.money(@value) }
      span(class: "text-foreground-muted w-8 text-end text-xs tabular-nums") { ActiveSupport::NumberHelper.number_to_percentage(@share, precision: 0, locale: I18n.locale) } if @share
    end
  end

  private
    def country_name
      I18n.t(@country, scope: "ui_components.countries", default: @country.to_s.upcase)
    end
end
