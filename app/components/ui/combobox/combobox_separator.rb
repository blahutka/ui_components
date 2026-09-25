# A thin divider between ComboboxGroups.
class UI::ComboboxSeparator < UI::Base
  def view_template
    div(**mix({ role: "separator", data: { slot: "combobox-separator" } }, @attributes.except(:class)),
      class: cn("bg-border mx-0 my-1.5 h-px shrink-0", override: @attributes[:class]))
  end
end
