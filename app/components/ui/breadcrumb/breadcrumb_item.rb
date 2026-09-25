# One crumb's <li>: a BreadcrumbLink, an ellipsis, or a menu of collapsed crumbs.
class UI::BreadcrumbItem < UI::Base
  def view_template(&)
    li(**mix({ data: { slot: "breadcrumb-item" } }, @attributes.except(:class)),
      class: cn("inline-flex items-center gap-1.5 [&_svg:not([class*='size-'])]:size-4", override: @attributes[:class]), &)
  end
end
