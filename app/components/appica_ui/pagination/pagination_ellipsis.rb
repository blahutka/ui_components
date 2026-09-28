# "…" for the pages collapsed out of a long range. Decorative, with a screen-reader-only
# "More pages" (translated).
class AppicaUI::PaginationEllipsis < AppicaUI::Base
  SIZES = { sm: "h-8 w-6 pb-1 [&_svg]:size-4", md: "h-10 w-7 pb-1.5 [&_svg]:size-4.5", lg: "h-12 w-8 pb-2 [&_svg]:size-5" }.freeze

  def view_template(&block)
    size = context[:ui_pagination]&.size || :md
    span(**mix({ data: { slot: "pagination-ellipsis" } }, @attributes.except(:class)),
      class: cn("text-foreground-strong inline-flex items-end justify-center", SIZES[size], override: @attributes[:class])) do
      if block
        yield
      else
        svg(aria_hidden: "true", viewBox: "0 0 20 20", fill: "currentColor") { |s| [ 4, 10, 16 ].each { |cx| s.circle(cx:, cy: "10", r: "1.5") } }
      end
      span(class: "sr-only") { t(".more") }
    end
  end
end
