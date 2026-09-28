require "test_helper"

class AppicaUI::BreadcrumbTest < ComponentTestCase
  test "a labelled nav with an ordered trail, separators and the current page" do
    trail = render_ui do
      Breadcrumb do
        BreadcrumbList do
          BreadcrumbItem { BreadcrumbLink(href: "/") { "Home" } }
          BreadcrumbSeparator()
          BreadcrumbItem { BreadcrumbLink(active: true) { "Page" } }
        end
      end
    end
    current = trail.at_css("span[data-slot=breadcrumb-link]")

    assert_equal "Breadcrumb", trail.at_css("nav[data-slot=breadcrumb]")["aria-label"]
    assert trail.at_css("nav > ol[data-slot=breadcrumb-list] > li[data-slot=breadcrumb-item] > a[href='/']")
    assert_equal [ "presentation", "true" ], trail.at_css("li[data-slot=breadcrumb-separator]").then { |separator| [ separator["role"], separator["aria-hidden"] ] }
    assert trail.at_css("[data-slot=breadcrumb-separator] svg.rtl\\:rotate-180")
    assert_equal [ "page", "-1", "true" ], [ current["aria-current"], current["tabindex"], current["data-active"] ]
    assert_equal "Drobečková navigace", I18n.with_locale(:cs) { render_ui { Breadcrumb() }.at_css("nav")["aria-label"] }
  end

  test "disabled crumbs, custom separators and the ellipsis" do
    trail = render_ui { BreadcrumbLink(disabled: true, href: "/x") { "Archive" }; BreadcrumbSeparator { "/" }; BreadcrumbEllipsis() }

    assert_nil trail.at_css("a")
    assert_equal "true", trail.at_css("span[data-slot=breadcrumb-link]")["aria-disabled"]
    assert_equal "/", trail.at_css("[data-slot=breadcrumb-separator]").text
    assert_equal "More", trail.at_css("[data-slot=breadcrumb-ellipsis] .sr-only").text
  end

  test "a block with an argument projects the crumb onto a Badge" do
    link = render_ui { BreadcrumbLink(href: "/") { |crumb| Badge(**crumb, variant: :soft) { "Home" } } }.at_css("a")
    current = render_ui { BreadcrumbLink(active: true) { |crumb| Badge(**crumb, variant: :soft) { "Here" } } }.at_css("span")

    assert_equal [ "/", "breadcrumb-link" ], [ link["href"], link["data-slot"] ]
    assert_includes link["class"], "data-[slot=breadcrumb-link]:not-data-active:text-foreground-muted"
    assert_equal [ "page", "breadcrumb-link" ], [ current["aria-current"], current["data-slot"] ]
  end
end
