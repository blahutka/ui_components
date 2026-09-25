# A thin divider between items or groups.
class UI::DropdownMenuSeparator < UI::Base
  def view_template
    menu = consume(:ui_dropdown_menu, component: "DropdownMenu")
    div(**mix({ role: "separator", aria_orientation: "horizontal", data: { slot: "#{menu.slot}-separator" } }, @attributes.except(:class)),
      class: cn("bg-border -mx-2 my-1.5 h-px shrink-0", override: @attributes[:class]))
  end
end
