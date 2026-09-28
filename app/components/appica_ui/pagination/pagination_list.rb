# The <ul> laying the pagination items out in a row.
class AppicaUI::PaginationList < AppicaUI::Base
  def view_template(&)
    ul(**mix({ data: { slot: "pagination-list" } }, @attributes.except(:class)), class: cn("flex items-center gap-1", override: @attributes[:class]), &)
  end
end
