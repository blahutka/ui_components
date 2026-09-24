# The popup for a menu. It opens below its trigger (to the inline-end side in a vertical bar)
# and flips when there isn't room.
class UI::MenubarContent < UI::Base
  PLACEMENT = {
    horizontal: "top-full start-0 mt-1.5 origin-top data-[side=top]:top-auto data-[side=top]:bottom-full data-[side=top]:mt-0 data-[side=top]:mb-1.5 data-[side=top]:origin-bottom",
    vertical: "start-full top-0 ms-1.5 origin-top-left rtl:origin-top-right data-[side=bottom]:top-full data-[side=bottom]:start-0 data-[side=bottom]:ms-0 data-[side=bottom]:mt-1.5"
  }.freeze

  def initialize(**attributes)
    @attributes = attributes
  end

  def view_template(&)
    div(**mix({
      id: menu.content_id,
      hidden: true,
      role: "menu",
      tabindex: "-1",
      aria: { labelledby: menu.trigger_id },
      data: { slot: "menubar-content", "ui--menubar-target": "content" }
    }, @attributes.except(:class)), class: cn(bar.popup_classes, PLACEMENT[bar.orientation], override: @attributes[:class])) do
      div(class: "flex flex-col gap-0.5 p-2", &)
    end
  end

  private
    def bar = consume(:ui_menubar, component: "Menubar")
    def menu = consume(:ui_menubar_menu, component: "MenubarMenu")
end
