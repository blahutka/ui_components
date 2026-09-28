# An "on this page" sidebar that highlights the links whose headings are in view.
#
#   Toc(aria_label: "On this page") do
#     TocList do
#       TocItem { TocLink(href: "#installation") { "Installation" } }
#       TocItem { TocLink(href: "#configuration", depth: 3) { "Configuration" } }
#     end
#   end
#
# Each link's `href` points at a heading's id; the `appica-ui--toc` controller watches those headings
# (IntersectionObserver), marks the links in view `data-active`, the topmost one
# aria-current="location", and slides the rail indicator over them. `root_margin:` offsets the
# boundary (e.g. "-64px 0px 0px 0px" under a sticky header); `container:` (a CSS selector) tracks a
# scrolling element instead of the page, and clicking a link scrolls that element.
class AppicaUI::Toc < AppicaUI::Base
  prop :aria_label,  default: -> { t(".label") }
  prop :root_margin, default: -> { "0px" }
  prop :container,   default: -> { nil }

  def view_template(&)
    nav(**mix({ aria_label: @aria_label, data: {
      slot: "toc", controller: "appica-ui--toc", "appica-ui--toc-root-margin-value": @root_margin, "appica-ui--toc-container-value": @container,
      action: ("click->appica-ui--toc#scroll" if @container)
    } }, @attributes.except(:class)), class: @attributes[:class], &)
  end
end
