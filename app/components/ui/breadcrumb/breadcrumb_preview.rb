# Where the current page sits in a hierarchy - a trail of links ending in the current page.
#
# @label Breadcrumb
# @logical_path Navigation
# @component UI::Breadcrumb
# @display width wide
class UI::BreadcrumbPreview < UI::BasePreview
  # @label Usage
  # Links before the last; the final crumb is `active` - plain text with aria-current="page".
  def default
    phlex do
      Breadcrumb do
        BreadcrumbList do
          BreadcrumbItem { BreadcrumbLink(href: "#!") { "Home" } }
          BreadcrumbSeparator()
          BreadcrumbItem { BreadcrumbLink(href: "#!") { "Components" } }
          BreadcrumbSeparator()
          BreadcrumbItem { BreadcrumbLink(active: true) { "Breadcrumb" } }
        end
      end
    end
  end

  # @label With icons
  # An icon inside a link is sized and spaced next to the label.
  def icons
    phlex do
      Breadcrumb do
        BreadcrumbList do
          BreadcrumbItem { BreadcrumbLink(href: "#!") { Icon(:home); plain "Home" } }
          BreadcrumbSeparator()
          BreadcrumbItem { BreadcrumbLink(href: "#!") { Icon(:folder); plain "Projects" } }
          BreadcrumbSeparator()
          BreadcrumbItem { BreadcrumbLink(active: true) { Icon(:file_text); plain "Roadmap" } }
        end
      end
    end
  end

  # @label Custom separators
  # Give BreadcrumbSeparator content - a slash, a dot, an icon.
  def separators
    phlex do
      div(class: "flex flex-col gap-5") do
        [ -> { plain "/" }, -> { span(class: "bg-foreground-muted size-0.75 rounded-full") } ].each do |mark|
          Breadcrumb do
            BreadcrumbList do
              BreadcrumbItem { BreadcrumbLink(href: "#!") { "Home" } }
              BreadcrumbSeparator(&mark)
              BreadcrumbItem { BreadcrumbLink(href: "#!") { "Docs" } }
              BreadcrumbSeparator(&mark)
              BreadcrumbItem { BreadcrumbLink(active: true) { "Breadcrumb" } }
            end
          end
        end
      end
    end
  end

  # @label Soft badges
  # A block with an argument projects each crumb onto a soft Badge: idle crumbs stay muted,
  # brighten on hover, and the current one is filled.
  def badges
    phlex do
      Breadcrumb do
        BreadcrumbList do
          BreadcrumbItem { BreadcrumbLink(href: "#!") { |crumb| Badge(**crumb, variant: :soft) { Icon(:home, data: { icon: "start" }); plain "Home" } } }
          BreadcrumbSeparator()
          BreadcrumbItem { BreadcrumbLink(href: "#!") { |crumb| Badge(**crumb, variant: :soft) { Icon(:components, data: { icon: "start" }); plain "Library" } } }
          BreadcrumbSeparator()
          BreadcrumbItem { BreadcrumbLink(active: true) { |crumb| Badge(**crumb, variant: :soft) { Icon(:components, data: { icon: "start" }); plain "Component" } } }
        end
      end
    end
  end

  # @label Collapsed trail
  # BreadcrumbEllipsis stands in for crumbs collapsed out of a long trail (it becomes a menu
  # trigger once DropdownMenu lands); a disabled crumb is dimmed and skipped by Tab.
  def collapsed
    phlex do
      Breadcrumb do
        BreadcrumbList do
          BreadcrumbItem { BreadcrumbLink(href: "#!") { "Home" } }
          BreadcrumbSeparator()
          BreadcrumbItem { BreadcrumbEllipsis(class: "size-6") }
          BreadcrumbSeparator()
          BreadcrumbItem { BreadcrumbLink(disabled: true) { "Archive" } }
          BreadcrumbSeparator()
          BreadcrumbItem { BreadcrumbLink(active: true) { "Collapsed" } }
        end
      end
    end
  end

  # @label RTL
  # The chevrons point the reading direction.
  def rtl
    phlex do
      div(dir: "rtl") do
        Breadcrumb(aria_label: "مسار التنقل") do
          BreadcrumbList do
            BreadcrumbItem { BreadcrumbLink(href: "#!") { "الرئيسية" } }
            BreadcrumbSeparator()
            BreadcrumbItem { BreadcrumbLink(href: "#!") { "المكونات" } }
            BreadcrumbSeparator()
            BreadcrumbItem { BreadcrumbLink(active: true) { "مسار التنقل" } }
          end
        end
      end
    end
  end
end
