# The divider between crumbs: a chevron (flipped for RTL) unless given content. Decorative.
class UI::BreadcrumbSeparator < UI::Base
  def view_template(&block)
    li(**mix({ role: "presentation", aria_hidden: "true", data: { slot: "breadcrumb-separator" } }, @attributes.except(:class)),
      class: cn("flex min-w-3.5 items-center justify-center text-center [&_svg:not([class*='size-'])]:size-3.5", override: @attributes[:class])) do
      if block
        yield
      else
        svg(viewBox: "0 0 14 14", fill: "currentColor", aria_hidden: "true", class: "rtl:rotate-180") do |s|
          s.path(d: "M4.808 3.058c.244-.244.641-.244.885 0l3.5 3.5c.244.244.244.641 0 .885l-3.5 3.5c-.244.244-.641.244-.885 0s-.244-.641 0-.885L7.865 7 4.808 3.942c-.244-.244-.244-.641 0-.885z")
        end
      end
    end
  end
end
