# A labelled section of a menu - give it a DropdownMenuGroupLabel.
class UI::DropdownMenuGroup < UI::Base
  def label_id
    @label_id ||= "menu-group-#{SecureRandom.hex(4)}"
  end

  def view_template(&)
    menu = consume(:ui_dropdown_menu, component: "DropdownMenu")
    provide(:ui_dropdown_menu_group, self) do
      div(**mix({ role: "group", aria_labelledby: label_id, data: { slot: "#{menu.slot}-group" } }, @attributes.except(:class)),
        class: cn("flex flex-col gap-0.5", override: @attributes[:class]), &)
    end
  end
end
