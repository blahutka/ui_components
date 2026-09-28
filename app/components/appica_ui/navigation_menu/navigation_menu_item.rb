# One entry of a NavigationMenu: a trigger with its content, or a single link. `value:` names it
# (for `default_value:`); one is generated otherwise.
class AppicaUI::NavigationMenuItem < AppicaUI::Base
  prop :value, default: -> { "item-#{SecureRandom.hex(3)}" }

  attr_reader :value

  def view_template(&)
    provide(:ui_navigation_menu_item, self) do
      li(**mix({ data: { slot: "navigation-menu-item", value: @value, "appica-ui--navigation-menu-target": "item" } }, @attributes), &)
    end
  end
end
