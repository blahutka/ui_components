# The menu's popup, placed against the trigger: `side:` (:bottom, :top, :inline_end,
# :inline_start), `align:` (:start, :center, :end), `side_offset:` and `align_offset:`.
class UI::DropdownMenuContent < UI::Base
  prop :side,         one_of(%i[ bottom top inline_end inline_start left right ], :bottom), default: -> { :bottom }
  prop :align,        one_of(%i[ start center end ], :start), default: -> { :start }
  prop :side_offset,  default: -> { 6 }
  prop :align_offset, default: -> { 0 }

  def view_template(&)
    menu = consume(:ui_dropdown_menu, component: "DropdownMenu")
    div(**mix({
      id: menu.content_id, popover: "manual", role: "menu", tabindex: "-1", aria_labelledby: menu.trigger_id,
      data: {
        slot: "#{menu.slot}-content", side: @side, align: @align, side_offset: @side_offset, align_offset: @align_offset,
        "#{menu.identifier}-target": "content"
      }
    }, @attributes.except(:class)), class: cn(menu.popup_classes, override: @attributes[:class])) do
      div(class: "flex flex-col gap-0.5 overflow-x-hidden overflow-y-auto p-2", &)
    end
  end
end
