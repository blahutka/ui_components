# One <li>: a PaginationLink or a PaginationEllipsis.
class UI::PaginationItem < UI::Base
  def view_template(&)
    li(**mix({ data: { slot: "pagination-item" } }, @attributes), &)
  end
end
