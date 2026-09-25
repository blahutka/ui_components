require "test_helper"

class UI::SliderTest < ComponentTestCase
  test "renders the track, fill and a thumb with a hidden range input" do
    slider = render_ui { Slider(default_value: 40, step: 5, name: "volume", thumb_aria_label: "Volume") }
    root = slider.at_css("[data-slot=slider]")
    input = slider.at_css("input[type=range]")

    assert_equal "ui--slider", root["data-controller"]
    assert_equal "horizontal", root["data-orientation"]
    assert_equal "inset-inline-start: 0%; width: 40.0%", slider.at_css("[data-slot=slider-indicator]")["style"]
    assert_includes slider.at_css("[data-slot=slider-thumb]")["style"], "inset-inline-start: 40.0%"
    assert_equal [ "volume", "40", "0", "100", "5", "Volume" ], %w[ name value min max step aria-label ].map { |attribute| input[attribute] }
    assert_equal "40", slider.at_css("[data-slot=slider-tooltip]").text
  end

  test "an array value renders a range with named ends" do
    slider = render_ui { Slider(default_value: [ 20, 80 ], name: "price", thumb_aria_label: %w[ Min Max ]) }
    inputs = slider.css("input[type=range]")

    assert_equal [ %w[ price[] 20 Min ], %w[ price[] 80 Max ] ], inputs.map { |input| [ input["name"], input["value"], input["aria-label"] ] }
    assert_equal "inset-inline-start: 20.0%; width: 60.0%", slider.at_css("[data-slot=slider-indicator]")["style"]
  end

  test "vertical, formatted, tooltip never and disabled" do
    slider = render_ui { Slider(default_value: 0.25, max: 1, step: 0.05, orientation: :vertical, format: { style: "percent" }, disabled: true) }
    never = render_ui { Slider(tooltip: :never) }

    assert_equal "bottom: 0%; height: 25.0%", slider.at_css("[data-slot=slider-indicator]")["style"]
    assert_equal "25%", slider.at_css("input")["aria-valuetext"]
    assert slider.at_css("input[disabled]")
    assert slider.at_css("[data-slot=slider][data-disabled]")
    assert_nil never.at_css("[data-slot=slider-tooltip]")
  end
end
