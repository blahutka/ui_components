# Key figures under a divider, in equal columns.
class AppicaUI::Blocks::RevenueStats < AppicaUI::Blocks::Base
  def view_template(&)
    Separator(class: "my-3")
    div(**mix({ data: { slot: "revenue-stats" } }, @attributes.except(:class)), class: cn("grid auto-cols-fr grid-flow-col gap-4", override: @attributes[:class]), &)
  end
end
