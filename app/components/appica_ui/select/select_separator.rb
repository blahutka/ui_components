# A thin divider between SelectGroups.
class AppicaUI::SelectSeparator < AppicaUI::Base
  def view_template
    div(**mix({ role: "separator", data: { slot: "select-separator" } }, @attributes.except(:class)),
      class: cn("bg-border -mx-2 my-1.5 h-px shrink-0", override: @attributes[:class]))
  end
end
