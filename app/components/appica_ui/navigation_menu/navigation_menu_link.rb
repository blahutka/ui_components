# A link in a NavigationMenu - inside a panel (a full-width pill row) or as a bar item.
# `active: true` marks the current page; `close_on_click: true` closes the menu (for in-page
# links or Turbo frames). A block taking an argument receives the attributes.
class AppicaUI::NavigationMenuLink < AppicaUI::Base
  prop :active,         default: -> { false }
  prop :close_on_click, default: -> { false }

  def before_template(&content)
    @render_prop = content&.arity == 1
    super
  end

  def view_template(&)
    menu = consume(:ui_navigation_menu, component: "NavigationMenu")
    in_panel = context[:ui_navigation_menu_content].present?
    vertical = in_panel || menu.nested? || menu.orientation == :vertical

    attributes = mix({
      aria_current: ("page" if @active),
      data: {
        slot: "navigation-menu-link", orientation: (vertical ? "vertical" : "horizontal"), active: ("true" if @active),
        "appica-ui--navigation-menu-target": ("barLink" unless in_panel), action: ("appica-ui--navigation-menu#close" if @close_on_click)
      }
    }.compact, @attributes.except(:class)).merge(
      class: cn(AppicaUI::NavigationLink.style(in_panel ? :pill : menu.variant, menu.size), ("w-full" if vertical), "outline-hidden", override: @attributes[:class])
    )

    if @render_prop
      yield attributes
    else
      a(**attributes, &)
    end
  end
end
