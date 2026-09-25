# One Toc entry's <li>.
class UI::TocItem < UI::Base
  def view_template(&)
    li(**mix({ data: { slot: "toc-item" } }, @attributes), &)
  end
end
