# The submenu popup. Opens to the inline-end side of its trigger, flipping near the edge.
class AppicaUI::MenubarSubContent < AppicaUI::Base
  PLACEMENT = "start-full top-0 -mt-2.25 ms-2.5 origin-top-left rtl:origin-top-right " \
    "data-[side=inline-start]:start-auto data-[side=inline-start]:end-full data-[side=inline-start]:ms-0 data-[side=inline-start]:me-2.5"

  def view_template(&)
    div(**mix({
      id: sub.content_id,
      hidden: true,
      role: "menu",
      tabindex: "-1",
      aria: { labelledby: sub.trigger_id },
      data: { slot: "menubar-sub-content" }
    }, @attributes.except(:class)), class: cn(bar.popup_classes, PLACEMENT, override: @attributes[:class])) do
      div(class: "flex flex-col gap-0.5 p-2", &)
    end
  end

  private
    def bar = consume(:ui_menubar, component: "Menubar")
    def sub = consume(:ui_menubar_sub, component: "MenubarSub")
end
