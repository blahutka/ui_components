# One NavigationLink's <li>.
class UI::NavigationItem < UI::Base
  def view_template(&)
    li(**mix({ data: { slot: "navigation-item" } }, @attributes), &)
  end
end
