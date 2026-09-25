require "test_helper"

class UI::ToggleTest < ComponentTestCase
  test "a standalone toggle flips itself and hands its attributes to a block" do
    button = render_ui { Toggle(pressed: true, aria_label: "Bold") { |toggle| Button(**toggle, variant: :outline, icon: true) { "B" } } }.at_css("button")

    assert_equal "true", button["aria-pressed"]
    assert button.key?("data-pressed")
    assert_equal "toggle", button["data-slot"]
    assert_equal "ui--toggle", button["data-controller"]
    assert_equal "Bold", button["aria-label"]
    assert_includes button["class"], "data-pressed:"
  end

  test "without a block argument it's a plain button" do
    button = render_ui { Toggle(disabled: true, class: "size-4") { "x" } }.at_css("button")

    assert_equal "false", button["aria-pressed"]
    assert button.key?("disabled")
    assert_equal "size-4", button["class"]
  end

  test "a group presses its values and manages the toggles" do
    group = render_ui do
      ToggleGroup(default_value: %w[ center ], multiple: true, orientation: :vertical, name: "align", aria_label: "Alignment") do
        Toggle(value: "left") { "L" }
        Toggle(value: "center") { "C" }
      end
    end
    root = group.at_css("[data-slot=toggle-group]")
    left, center = group.css("button")

    assert_equal "group", root["role"]
    assert_equal "vertical", root["data-orientation"]
    assert_equal "true", root["data-ui--toggle-group-multiple-value"]
    assert_equal [ "false", "true" ], [ left["aria-pressed"], center["aria-pressed"] ]
    assert_nil left["data-controller"]
    assert_equal "item", left["data-ui--toggle-group-target"]
    assert_equal [ "align[]", "center" ], group.at_css("input[type=hidden]").then { |input| [ input["name"], input["value"] ] }
  end
end
