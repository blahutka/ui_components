require "test_helper"

class UI::IconTest < ComponentTestCase
  test "outline icons render the stroke style at 24px, decorative" do
    svg = render_ui { Icon(:star) }.at_css("svg")

    assert_equal "appica-icon", svg["class"]
    assert_equal "star", svg["data-name"]
    assert_equal "0 0 24 24", svg["viewBox"]
    assert_equal "24", svg["width"]
    assert_equal "none", svg["fill"]
    assert_equal "currentColor", svg["stroke"]
    assert_equal "1.5", svg["stroke-width"]
    assert_equal "round", svg["stroke-linecap"]
    assert_equal "true", svg["aria-hidden"]
    assert svg.at_css("path")
  end

  test "filled icons fill with currentColor and ignore the stroke width" do
    svg = render_ui { Icon(:star_filled, stroke_width: 2) }.at_css("svg")

    assert_equal "currentColor", svg["fill"]
    assert_nil svg["stroke"]
    assert_nil svg["stroke-width"]
  end

  test "size, stroke width, color and classes" do
    svg = render_ui { Icon("arrow-back-up", size: 20, stroke_width: 2, color: "red", class: "text-primary") }.at_css("svg")

    assert_equal [ "20", "20" ], [ svg["width"], svg["height"] ]
    assert_equal "2", svg["stroke-width"]
    assert_equal "red", svg["color"]
    assert_equal "appica-icon text-primary", svg["class"]
  end

  test "an aria_label makes it an image instead of decoration" do
    svg = render_ui { Icon(:x, aria_label: "Close") }.at_css("svg")

    assert_equal "img", svg["role"]
    assert_equal "Close", svg["aria-label"]
    assert_nil svg["aria-hidden"]
  end

  test "names normalize from symbols and React names" do
    assert_equal "sort-0-9", UI::IconLibrary.normalize(:sort_0_9)
    assert_equal "sort-0-9", UI::IconLibrary.normalize("Sort0_9")
    assert_equal "arrow-back-up", UI::IconLibrary.normalize("ArrowBackUp")
    assert_equal "star-filled", render_ui { Icon("StarFilled") }.at_css("svg")["data-name"]
  end

  test "an unknown name raises with suggestions" do
    error = assert_raises(KeyError) { UI::IconLibrary.fetch(:strar) }

    assert_includes error.message, "Did you mean: star"
  end
end
