# The ordered list of crumbs and separators; wraps on narrow screens.
class UI::BreadcrumbList < UI::Base
  def view_template(&)
    ol(**mix({ data: { slot: "breadcrumb-list" } }, @attributes.except(:class)),
      class: cn("flex flex-wrap items-center gap-1.5 wrap-break-word [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='stroke-'])]:stroke-[1.85]",
        override: @attributes[:class]), &)
  end
end
