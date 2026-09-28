# The item that opens a submenu, with a trailing chevron. Opens on hover, click or →.
class AppicaUI::MenubarSubTrigger < AppicaUI::Base
  prop :disabled, default: -> { false }
  prop :label,    default: -> { nil }

  def view_template(&)
    div(**mix({
      id: sub.trigger_id,
      role: "menuitem",
      tabindex: "-1",
      aria: { haspopup: "menu", expanded: "false", controls: sub.content_id, disabled: (@disabled ? "true" : nil) },
      data: { slot: "menubar-sub-trigger", orientation: "vertical", disabled: (@disabled ? "" : nil), label: @label }
    }, @attributes.except(:class)), class: cn(bar.item_classes, "justify-between", override: @attributes[:class])) do
      span(class: "flex flex-1 items-center gap-1.5", &)
      render AppicaUI::Icon.new(:chevron_right, stroke_width: 2, class: "size-4.5 shrink-0 rtl:rotate-180", data: { icon: "end" })
    end
  end

  private
    def bar = consume(:ui_menubar, component: "Menubar")
    def sub = consume(:ui_menubar_sub, component: "MenubarSub")
end
