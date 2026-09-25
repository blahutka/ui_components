# The <ul> of NavigationItems: a row, or a column for a vertical navigation.
class UI::NavigationList < UI::Base
  def view_template(&)
    navigation = consume(:ui_navigation, component: "Navigation")
    ul(**mix({ role: "list", data: { slot: "navigation-list" } }, @attributes.except(:class)),
      class: cn(navigation.list_classes, override: @attributes[:class]), &)
  end
end
