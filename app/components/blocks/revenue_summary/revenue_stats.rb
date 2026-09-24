# Key figures under a divider, in equal columns.
class Blocks::RevenueStats < Blocks::Base
  def initialize(**attributes)
    @attributes = attributes
  end

  def view_template(&)
    hr(class: "border-border my-3 w-full shrink-0 border-t", data: { slot: "separator" })
    div(**mix({ data: { slot: "revenue-stats" } }, @attributes.except(:class)), class: cn("grid auto-cols-fr grid-flow-col gap-4", override: @attributes[:class]), &)
  end
end
