# A nested submenu: DropdownMenuSubTrigger plus DropdownMenuSubContent.
class AppicaUI::DropdownMenuSub < AppicaUI::Base
  prop :id, default: -> { "menu-sub-#{SecureRandom.hex(4)}" }

  attr_reader :id

  def trigger_id = "#{@id}-trigger"
  def content_id = "#{@id}-content"

  def view_template(&)
    menu = consume(:ui_dropdown_menu, component: "DropdownMenu")
    provide(:ui_dropdown_menu_sub, self) do
      div(**mix({ id: @id, data: { slot: "#{menu.slot}-sub" } }, @attributes.except(:class)), class: cn("flex flex-col", override: @attributes[:class]), &)
    end
  end
end
