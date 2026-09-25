# A submenu's popup - beside its trigger (inline-end, flipping at the edge).
class UI::DropdownMenuSubContent < UI::Base
  prop :side_offset, default: -> { 12 }

  def view_template(&)
    menu = consume(:ui_dropdown_menu, component: "DropdownMenu")
    sub = consume(:ui_dropdown_menu_sub, component: "DropdownMenuSub")
    div(**mix({
      id: sub.content_id, popover: "manual", role: "menu", tabindex: "-1", aria_labelledby: sub.trigger_id,
      data: { slot: "#{menu.slot}-sub-content", side: "inline_end", align: "start", side_offset: @side_offset, align_offset: -9 }
    }, @attributes.except(:class)), class: cn(menu.popup_classes, override: @attributes[:class])) do
      div(class: "flex flex-col gap-0.5 overflow-x-hidden overflow-y-auto p-2", &)
    end
  end
end
