# The top-level label that opens its menu. Once a menu is open, hovering a sibling trigger
# switches to it; arrow keys move along the bar.
class AppicaUI::MenubarTrigger < AppicaUI::Base
  prop :disabled, default: -> { false }

  def view_template(&)
    disabled = @disabled || menu.disabled?

    button(**mix({
      type: "button",
      id: menu.trigger_id,
      role: "menuitem",
      tabindex: "-1",
      aria: { haspopup: "menu", expanded: "false", controls: menu.content_id, disabled: disabled.to_s },
      data: {
        slot: "menubar-trigger",
        orientation: bar.orientation,
        disabled: (disabled ? "" : nil),
        "appica-ui--menubar-target": "trigger",
        action: "click->appica-ui--menubar#toggle pointerenter->appica-ui--menubar#switch"
      }
    }, @attributes.except(:class)), class: cn(bar.trigger_classes, override: @attributes[:class]), &)
  end

  private
    def bar = consume(:ui_menubar, component: "Menubar")
    def menu = consume(:ui_menubar_menu, component: "MenubarMenu")
end
