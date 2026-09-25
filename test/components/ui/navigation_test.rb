require "test_helper"

class UI::NavigationTest < ComponentTestCase
  def render_navigation(**options)
    render_ui do
      Navigation(aria_label: "Main", **options) do
        NavigationList do
          NavigationItem { NavigationLink(href: "/a", value: "a") { "A" } }
          NavigationItem { NavigationLink(href: "/b", value: :b) { "B" } }
          NavigationItem { NavigationLink(href: "/c", disabled: true) { "C" } }
        end
      end
    end
  end

  test "a nav landmark whose active_link marks the matching link current" do
    nav = render_navigation(active_link: "b")
    links = nav.css("a[data-slot=navigation-link]")

    assert_equal [ "Main", "pill", "horizontal" ], nav.at_css("nav").then { |element| [ element["aria-label"], element["data-variant"], element["data-orientation"] ] }
    assert_equal "list", nav.at_css("ul[data-slot=navigation-list]")["role"]
    assert_includes nav.at_css("ul")["class"], "gap-0.5"
    assert_equal [ nil, "page", nil ], links.map { |link| link["aria-current"] }
    assert_equal "true", links[1]["data-active"]
    assert_equal [ "true", "-1" ], [ links[2]["aria-disabled"], links[2]["tabindex"] ]
    assert_includes links[0]["class"], "hover:before:bg-background-muted"
  end

  test "line and vertical variants, active overrides and sizes" do
    nav = render_navigation(variant: :line, orientation: :vertical, size: :lg, active_link: "a")
    link = nav.at_css("a")
    forced = render_ui { Navigation(active_link: "x") { NavigationLink(href: "/", value: "x", active: false) { "X" } } }.at_css("a")

    assert_includes nav.at_css("ul")["class"], "flex-col"
    assert_equal "vertical", link["data-orientation"]
    assert_includes link["class"], "data-active:data-[orientation=vertical]:after:bg-size-[2px_100%]"
    assert_includes link["class"], "text-base"
    assert_nil forced["aria-current"]
  end

  test "the indicator variant wraps the label beside a chevron; a render prop gets the attributes" do
    link = render_ui { Navigation(variant: :indicator, orientation: :vertical, active_link: "t") { NavigationLink(href: "/", value: "t") { "Theming" } } }.at_css("a")
    button = render_ui { Navigation(active_link: "t") { NavigationLink(value: "t") { |attributes| button(**attributes, type: "button") { "T" } } } }.at_css("button")

    assert link.at_css("[data-slot=navigation-link-indicator][aria-hidden=true] svg")
    assert_equal "Theming", link.at_css("[data-slot=navigation-link-label]").text
    assert_equal [ "page", "navigation-link" ], [ button["aria-current"], button["data-slot"] ]
    assert_includes button["class"], "inline-flex"
  end
end
