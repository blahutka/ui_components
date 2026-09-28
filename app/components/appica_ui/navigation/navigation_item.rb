# One NavigationLink's <li>.
class AppicaUI::NavigationItem < AppicaUI::Base
  def view_template(&)
    li(**mix({ data: { slot: "navigation-item" } }, @attributes), &)
  end
end
