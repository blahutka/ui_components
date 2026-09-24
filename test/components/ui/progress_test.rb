require "test_helper"

class UI::ProgressTest < ComponentTestCase
  test "renders a bar with label, value and track" do
    html = render_ui do
      Progress(value: 60) do
        ProgressLabel { "Uploading" }
        ProgressValue()
      end
    end
    progress = html.at_css("[data-slot=progress]")

    assert_equal "progressbar", progress["role"]
    assert_equal "bar", progress["data-variant"]
    assert progress.key?("data-progressing")
    assert_equal "60%", progress["aria-valuetext"]
    assert_equal html.at_css("[data-slot=progress-label]")["id"], progress["aria-labelledby"]
    assert_includes progress["style"], "--progress-color: var(--primary)"
    assert_equal "height: 6px", html.at_css("[data-slot=progress-track]")["style"]
    assert_includes html.at_css("[data-slot=progress-indicator]")["style"], "width: 60.0%"
    assert_equal "60%", html.at_css("[data-slot=progress-value]").text
  end

  test "circular draws a ring whose offset follows the value" do
    html = render_ui { Progress(variant: :circular, value: 72, size: 64, indicator_color: "red") { ProgressValue() } }
    ring = html.at_css("circle[data-slot=progress-indicator]")

    assert_equal "64", html.at_css("[data-slot=progress-circular]")["width"]
    assert_equal "30.0", ring["r"]
    assert_in_delta 52.7788, ring["stroke-dashoffset"].to_f, 0.001
    assert_equal "4", ring["stroke-width"]
    assert_includes html.at_css("[data-slot=progress]")["style"], "--progress-color: red"
  end

  test "complete and indeterminate states" do
    complete = render_ui { Progress(value: 100) }.at_css("[data-slot=progress]")
    indeterminate = render_ui { Progress(value: nil) }

    assert complete.key?("data-complete")
    assert indeterminate.at_css("[data-slot=progress]").key?("data-indeterminate")
    assert_nil indeterminate.at_css("[data-slot=progress]")["aria-valuenow"]
    assert_nil indeterminate.at_css("[data-slot=progress-indicator]")["style"]
  end
end
