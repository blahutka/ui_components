# The panel of a NavigationMenuItem - lay links out inside however you like (a list, a grid, a
# featured card). Rendered hidden in its item (so it's crawlable) and shown in the menu's popup.
class UI::NavigationMenuContent < UI::Base
  PADDING = { sm: "p-1.5", md: "p-2", lg: "p-2.5" }.freeze

  def view_template(&)
    menu = consume(:ui_navigation_menu, component: "NavigationMenu")
    item = consume(:ui_navigation_menu_item, component: "NavigationMenuItem")
    open = menu.open?(item.value)

    provide(:ui_navigation_menu_content, true) do
      div(**mix({
        id: "#{menu.id}-content-#{item.value}", role: "group", aria_labelledby: "#{menu.id}-trigger-#{item.value}", hidden: !open,
        data: { slot: "navigation-menu-content", value: item.value, "ui--navigation-menu-target": "content" }
      }, @attributes.except(:class)),
        class: cn(PADDING[menu.size], "motion-safe:transition-opacity motion-safe:duration-350 motion-safe:ease-[cubic-bezier(0.22,1,0.36,1)] data-starting-style:motion-safe:opacity-0",
          override: @attributes[:class]), &)
    end
  end
end
