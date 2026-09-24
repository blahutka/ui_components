# The "Top markets" list.
class Blocks::RevenueMarkets < Blocks::Base
  prop :title, default: -> { "Top markets" }

  def view_template(&)
    div(**mix({ data: { slot: "revenue-markets" } }, @attributes.except(:class)), class: cn("mt-4 flex flex-col gap-2.5", override: @attributes[:class])) do
      span(class: "text-foreground-muted text-xs") { @title }
      yield
    end
  end
end
