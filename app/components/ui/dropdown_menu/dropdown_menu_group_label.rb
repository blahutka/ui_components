# The heading of a DropdownMenuGroup or DropdownMenuRadioGroup.
class UI::DropdownMenuGroupLabel < UI::Base
  def view_template(&)
    menu = consume(:ui_dropdown_menu, component: "DropdownMenu")
    div(**mix({ id: context[:ui_dropdown_menu_group]&.label_id, data: { slot: "#{menu.slot}-group-label" } }, @attributes.except(:class)),
      class: cn("text-foreground-subtle", menu.label_classes, override: @attributes[:class]), &)
  end
end
