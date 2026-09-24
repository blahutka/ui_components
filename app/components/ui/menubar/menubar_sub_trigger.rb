# The item that opens a submenu, with a trailing chevron. Opens on hover, click or →.
class UI::MenubarSubTrigger < UI::Base
  def initialize(disabled: false, label: nil, **attributes)
    @disabled, @label = disabled, label
    @attributes = attributes
  end

  def view_template(&)
    div(**mix({
      id: sub.trigger_id,
      role: "menuitem",
      tabindex: "-1",
      aria: { haspopup: "menu", expanded: "false", controls: sub.content_id, disabled: (@disabled ? "true" : nil) },
      data: { slot: "menubar-sub-trigger", orientation: "vertical", disabled: (@disabled ? "" : nil), label: @label }
    }, @attributes.except(:class)), class: cn(bar.item_classes, "justify-between", override: @attributes[:class])) do
      span(class: "flex flex-1 items-center gap-1.5", &)
      svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 16 16", fill: "currentColor", aria_hidden: "true", class: "size-4.5 shrink-0 rtl:rotate-180", data: { icon: "end" }) do |s|
        s.path(d: "M5.558 3.558c.244-.244.641-.244.885 0l4 4c.244.244.244.641 0 .885l-4 4c-.244.244-.641.244-.885 0s-.244-.641 0-.885L9.115 8 5.558 4.442c-.244-.244-.244-.641 0-.885z")
      end
    end
  end

  private
    def bar = consume(:ui_menubar, component: "Menubar")
    def sub = consume(:ui_menubar_sub, component: "MenubarSub")
end
