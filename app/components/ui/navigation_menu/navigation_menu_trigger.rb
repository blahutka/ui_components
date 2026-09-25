# The label that opens its item's panel - on hover, click, Enter / Space or the arrow key toward
# the panel. Styled like a Navigation link. `disabled: true` dims it.
class UI::NavigationMenuTrigger < UI::Base
  prop :disabled, default: -> { false }

  def view_template(&)
    menu = consume(:ui_navigation_menu, component: "NavigationMenu")
    item = consume(:ui_navigation_menu_item, component: "NavigationMenuItem")
    vertical = menu.nested? || menu.orientation == :vertical
    open = menu.open?(item.value)

    button(**mix({
      type: "button", id: "#{menu.id}-trigger-#{item.value}", aria_expanded: open.to_s, aria_controls: "#{menu.id}-content-#{item.value}",
      disabled: (true if @disabled),
      data: {
        slot: "navigation-menu-trigger", orientation: (vertical ? "vertical" : "horizontal"), value: item.value,
        popup_open: ("" if open), disabled: ("" if @disabled), "ui--navigation-menu-target": "trigger",
        action: "click->ui--navigation-menu#toggle pointerenter->ui--navigation-menu#hover"
      }
    }, @attributes.except(:class)),
      class: cn(UI::NavigationLink.style(menu.nested? ? :pill : menu.variant, menu.size), ("w-full" if vertical), "outline-hidden",
        ("relative z-50" if menu.backdrop?), override: @attributes[:class]), &)
  end
end
