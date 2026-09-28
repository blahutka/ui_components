# One Toc entry's <li>.
class AppicaUI::TocItem < AppicaUI::Base
  def view_template(&)
    li(**mix({ data: { slot: "toc-item" } }, @attributes), &)
  end
end
