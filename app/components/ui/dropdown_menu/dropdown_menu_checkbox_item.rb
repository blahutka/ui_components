# A toggleable item with a check. Keeps the menu open and emits `checked-change` { item, checked }.
class UI::DropdownMenuCheckboxItem < UI::DropdownMenuItem
  prop :checked,        default: -> { false }
  prop :close_on_click, default: -> { false }

  def view_template(&)
    attributes = item_attributes("checkbox-item", role: "menuitemcheckbox").deep_merge(
      aria_checked: @checked.to_s, data: { checked: ("" if @checked), unchecked: ("" unless @checked) }
    )
    div(**mix(attributes, @attributes.except(:class)), class: cn(menu.item_classes("justify-between"), override: @attributes[:class])) do
      span(class: "flex items-center #{menu.gap}", &)
      indicator("checkbox-item", @checked)
    end
  end
end
