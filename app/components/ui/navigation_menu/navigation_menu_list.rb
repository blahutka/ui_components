# The row (or column) of NavigationMenuItems.
class UI::NavigationMenuList < UI::Base
  GAPS = { horizontal: { pill: "gap-0.5", line: "gap-7" }, vertical: { pill: "gap-0.5", line: "" } }.freeze

  def view_template(&)
    menu = consume(:ui_navigation_menu, component: "NavigationMenu")
    vertical = menu.orientation == :vertical
    ul(**mix({ data: { slot: "navigation-menu-list", "ui--navigation-menu-target": "list" } }, @attributes.except(:class)),
      class: cn("flex", (vertical ? "w-full flex-col" : "w-fit items-center"), GAPS[menu.orientation][menu.variant], override: @attributes[:class]), &)
  end
end
