# The item that opens a submenu, with a trailing chevron - on hover, click or the arrow toward it.
class UI::DropdownMenuSubTrigger < UI::DropdownMenuItem
  CHEVRON = "M5.558 3.558c.244-.244.641-.244.885 0l4 4c.244.244.244.641 0 .885l-4 4c-.244.244-.641.244-.885 0s-.244-.641 0-.885L9.115 8 5.558 4.442c-.244-.244-.244-.641 0-.885z"

  def view_template(&)
    sub = consume(:ui_dropdown_menu_sub, component: "DropdownMenuSub")
    attributes = item_attributes("sub-trigger").deep_merge(id: sub.trigger_id, aria_haspopup: "menu", aria_expanded: "false", aria_controls: sub.content_id)
    attributes[:data].delete(:close)

    div(**mix(attributes, @attributes.except(:class)), class: cn(menu.item_classes("justify-between"), override: @attributes[:class])) do
      span(class: "flex flex-1 items-center #{menu.gap}", &)
      svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 16 16", fill: "currentColor", aria_hidden: "true", data: { icon: "end" },
        class: "#{menu.chevron} shrink-0 rtl:rotate-180") { |s| s.path(d: CHEVRON) }
    end
  end
end
