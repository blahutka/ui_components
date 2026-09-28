# One option of a DropdownMenuRadioGroup; checked when the group's value matches. Keeps the menu open.
class AppicaUI::DropdownMenuRadioItem < AppicaUI::DropdownMenuItem
  prop :value,          proc(&:to_s)
  prop :close_on_click, default: -> { false }

  def view_template(&)
    checked = context[:ui_dropdown_menu_radio_group]&.value == @value
    attributes = item_attributes("radio-item", role: "menuitemradio").deep_merge(
      aria_checked: checked.to_s, data: { value: @value, checked: ("" if checked), unchecked: ("" unless checked) }
    )
    div(**mix(attributes, @attributes.except(:class)), class: cn(menu.item_classes("justify-between"), override: @attributes[:class])) do
      span(class: "flex items-center #{menu.gap}", &)
      indicator("radio-item", checked)
    end
  end
end
