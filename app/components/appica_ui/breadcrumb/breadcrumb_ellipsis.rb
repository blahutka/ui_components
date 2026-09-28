# A "…" for crumbs collapsed out of a long trail - usually a menu trigger's content. The dots are
# decorative; a screen-reader-only "More" (translated) names it.
class AppicaUI::BreadcrumbEllipsis < AppicaUI::Base
  def view_template(&block)
    span(**mix({ data: { slot: "breadcrumb-ellipsis" } }, @attributes.except(:class)),
      class: cn("inline-flex items-center justify-center [&_svg]:size-4.5!", override: @attributes[:class])) do
      if block
        yield
      else
        svg(aria_hidden: "true", viewBox: "0 0 20 20", fill: "currentColor") do |s|
          [ 4, 10, 16 ].each { |cx| s.circle(cx:, cy: "10", r: "1.5") }
        end
      end
      span(class: "sr-only") { t(".more") }
    end
  end
end
