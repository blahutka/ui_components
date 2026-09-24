require "test_helper"

class UI::SpinnerTest < ComponentTestCase
  test "renders a labelled status with the circular variant by default" do
    spinner = render_ui { Spinner() }.at_css("[data-slot=spinner]")

    assert_equal "status", spinner["role"]
    assert_equal "Loading", spinner["aria-label"]
    assert_equal "circular", spinner["data-variant"]
    assert_includes spinner["class"], "text-[2.5rem]"
    assert_includes spinner.at_css("svg")["class"], "text-primary"
    assert_equal "stroke-dashoffset", spinner.at_css("animate")["attributeName"]
    assert_equal "indefinite", spinner.at_css("animate")["repeatCount"]
  end

  test "each variant has an animated and a reduced-motion frame" do
    %i[ circular dots sparkle ].each do |variant|
      svg = render_ui { Spinner(variant:) }.at_css("svg")

      assert svg.at_css(".motion-reduce\\:hidden"), "#{variant} animated frame"
      assert svg.at_css(".motion-reduce\\:inline"), "#{variant} static frame"
    end
  end

  test "dots stagger twelve ticks and sparkle morphs with splines" do
    dots = render_ui { Spinner(variant: :dots) }
    sparkle = render_ui { Spinner(variant: :sparkle) }

    assert_equal 12, dots.css("g.motion-reduce\\:hidden rect").size
    assert_equal "-1.2s", dots.at_css("animate")["begin"]
    assert_equal "spline", sparkle.at_css("animate")["calcMode"]
    assert_equal "rotate", sparkle.at_css("animateTransform")["type"]
  end

  test "current_color inherits the text color and class overrides the size" do
    spinner = render_ui { Spinner(current_color: true, class: "text-xl", aria_label: "Saving") }.at_css("[data-slot=spinner]")

    assert_includes spinner.at_css("svg")["class"], "text-current"
    assert_includes spinner["class"], "text-xl"
    assert_not_includes spinner["class"], "text-[2.5rem]"
    assert_equal "Saving", spinner["aria-label"]
  end
end
