# Where the current page sits in a hierarchy: a `<nav>` landmark around a trail of links.
#
#   Breadcrumb do
#     BreadcrumbList do
#       BreadcrumbItem { BreadcrumbLink(href: root_path) { "Home" } }
#       BreadcrumbSeparator()
#       BreadcrumbItem { BreadcrumbLink(href: projects_path) { "Projects" } }
#       BreadcrumbSeparator()
#       BreadcrumbItem { BreadcrumbLink(active: true) { @project.name } }
#     end
#   end
#
# Plain semantic parts with no state. `aria_label:` names the landmark ("Breadcrumb", translated).
class UI::Breadcrumb < UI::Base
  prop :aria_label, default: -> { t(".label") }

  def view_template(&)
    nav(**mix({ aria_label: @aria_label, data: { slot: "breadcrumb" } }, @attributes.except(:class)),
      class: cn("text-foreground-muted w-fit text-sm font-medium", override: @attributes[:class]), &)
  end
end
