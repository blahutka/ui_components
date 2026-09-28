require "test_helper"

class AppicaUI::SeparatorTest < ComponentTestCase
  test "renders a horizontal solid rule by default" do
    separator = render_ui { Separator() }.at_css("[data-slot=separator]")

    assert_equal "separator", separator["role"]
    assert_equal "horizontal", separator["aria-orientation"]
    assert_equal "horizontal", separator["data-orientation"]
    assert_includes separator["class"], "border-solid"
    assert_includes separator["class"], "text-border"
  end

  test "vertical and css variants" do
    html = render_ui do
      Separator(orientation: :vertical, variant: :dashed)
      Separator(variant: :double)
      Separator(variant: :gradient, class: "text-primary")
    end
    dashed, double, gradient = html.css("[data-slot=separator]")

    assert_equal "vertical", dashed["aria-orientation"]
    assert_includes dashed["class"], "border-dashed"
    assert_includes double["class"], "border-double"
    assert_includes gradient["class"], "linear-gradient"
    assert_includes gradient["class"], "text-primary"
    refute_includes gradient["class"], "text-border "
  end

  test "pattern variants draw a repeating svg" do
    html = render_ui { Separator(variant: :zigzag); Separator(variant: :wave, orientation: :vertical) }
    zigzag, wave = html.css("[data-slot=separator]")

    assert_equal "M0 6 L4 2 L8 6 L12 2 L16 6", zigzag.at_css("pattern path")["d"]
    assert_equal "url(##{zigzag.at_css("pattern")["id"]})", zigzag.at_css("rect")["fill"]
    assert_equal "8", wave.at_css("svg")["width"]
    assert_equal "rotate(90) translate(0 -8)", wave.at_css("pattern")["patternTransform"]
  end
end
