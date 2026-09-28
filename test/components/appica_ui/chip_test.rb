require "test_helper"

class AppicaUI::ChipTest < ComponentTestCase
  test "renders a button with the variant and size" do
    chip = render_ui { Chip(variant: :primary, size: :sm) { "Tag" } }.at_css("button[data-slot=chip]")

    assert_equal "primary", chip["data-variant"]
    assert_equal "sm", chip["data-size"]
    assert_includes chip["class"], "bg-primary"
    assert_includes chip["class"], "h-6"
    assert_equal "Tag", chip.text
  end

  test "dismissible chips get a wrapper controller, a close icon and a translated label" do
    wrapper = render_ui { Chip(dismissible: true) { "React" } }.at_css("[data-slot=chip-wrapper]")

    assert_equal "appica-ui--chip", wrapper["data-controller"]
    assert_equal "appica-ui--chip#dismiss", wrapper.at_css("[data-slot=chip]")["data-action"]
    assert wrapper.at_css("svg[data-slot=chip-close-icon][data-icon=end]")
    assert_equal "Dismiss", wrapper.at_css(".sr-only").text
    assert_equal "Odebrat", I18n.with_locale(:cs) { render_ui { Chip(dismissible: true) { "x" } }.at_css(".sr-only").text }
  end

  test "href renders a link; a group shares variant and size" do
    link = render_ui { Chip(href: "#design") { "#design" } }.at_css("a[data-slot=chip]")
    group = render_ui { ChipGroup(variant: :outline, size: :lg) { Chip { "a" }; Chip(variant: :primary) { "b" } } }

    assert_equal "#design", link["href"]
    assert_equal [ %w[ outline lg ], %w[ primary lg ] ], group.css("[data-slot=chip]").map { |chip| [ chip["data-variant"], chip["data-size"] ] }
    assert_equal "appica-ui--chip-group", group.at_css("[data-slot=chip-group]")["data-controller"]
  end
end
