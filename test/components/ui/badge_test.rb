require "test_helper"

class UI::BadgeTest < ComponentTestCase
  test "renders a primary md span by default" do
    badge = render_ui { Badge { "Badge" } }.at_css("[data-slot=badge]")

    assert_equal "SPAN", badge.name.upcase
    assert_equal "primary", badge["data-variant"]
    assert_equal "md", badge["data-size"]
    assert_includes badge["class"], "bg-primary"
    assert_includes badge["class"], "h-6"
    assert_equal "Badge", badge.text
  end

  test "variant and size switch the classes and data attributes" do
    badge = render_ui { Badge(variant: :primary_outline, size: :icon_lg, aria_label: "Featured") { "★" } }.at_css("[data-slot=badge]")

    assert_equal "primary-outline", badge["data-variant"]
    assert_equal "icon-lg", badge["data-size"]
    assert_equal "Featured", badge["aria-label"]
    assert_includes badge["class"], "before:border-primary"
    assert_includes badge["class"], "h-7 w-7"
  end

  test "href renders a link and as: :button a button" do
    html = render_ui do
      Badge(href: "#design") { "Design" }
      Badge(as: :button) { "Follow" }
    end

    assert_equal "#design", html.at_css("a[data-slot=badge]")["href"]
    assert_equal "button", html.at_css("button[data-slot=badge]")["type"]
  end

  test "caller classes override the defaults" do
    classes = render_ui { Badge(size: :xs, class: "px-1 font-medium") { "3" } }.at_css("[data-slot=badge]")["class"].split

    assert_includes classes, "px-1"
    assert_not_includes classes, "px-1.5"
  end

  test "unknown variant and size fall back to the defaults" do
    badge = render_ui { Badge(variant: :nope, size: :huge) { "x" } }.at_css("[data-slot=badge]")

    assert_equal "primary", badge["data-variant"]
    assert_equal "md", badge["data-size"]
  end
end
