# One <li>: a PaginationLink or a PaginationEllipsis.
class AppicaUI::PaginationItem < AppicaUI::Base
  def view_template(&)
    li(**mix({ data: { slot: "pagination-item" } }, @attributes), &)
  end
end
