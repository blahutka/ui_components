# Where panels show for a `viewport: false` NavigationMenu - next to its list, for switching
# panels inline (a category sidebar beside a detail pane).
class UI::NavigationMenuViewport < UI::Base
  def view_template
    div(**mix({ data: { slot: "navigation-menu-viewport", "ui--navigation-menu-target": "viewport" } }, @attributes.except(:class)),
      class: cn("relative overflow-hidden", override: @attributes[:class]))
  end
end
