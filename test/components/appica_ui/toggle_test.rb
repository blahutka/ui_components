require "test_helper"

class AppicaUI::ToggleTest < ComponentTestCase
  test "a standalone toggle flips itself and hands its attributes to a block" do
    button = render_ui { Toggle(pressed: true, aria_label: "Bold") { |toggle| Button(**toggle, variant: :outline, icon: true) { "B" } } }.at_css("button")

    assert_equal "true", button["aria-pressed"]
    assert button.key?("data-pressed")
    assert_equal "toggle", button["data-slot"]
    assert_equal "appica-ui--toggle", button["data-controller"]
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
    assert_equal "true", root["data-appica-ui--toggle-group-multiple-value"]
    assert_equal [ "false", "true" ], [ left["aria-pressed"], center["aria-pressed"] ]
    assert_nil left["data-controller"]
    assert_equal "item", left["data-appica-ui--toggle-group-target"]
    assert_equal [ "align[]", "center" ], group.at_css("input[type=hidden]").then { |input| [ input["name"], input["value"] ] }
  end

  test "a named standalone toggle keeps a hidden input at its pressed or released value" do
    html = render_ui { Toggle(name: "featured", value: "1", unchecked_value: "0", pressed: false) { "Featured" } }

    hidden = html.at_css("input[type=hidden][name=featured]")
    assert_equal [ "0", "1", "0" ], [ hidden["value"], hidden["data-checked-value"], hidden["data-unchecked-value"] ]
    assert_equal hidden, html.at_css("button").previous_element

    hidden = render_ui { Toggle(name: "bold", value: "on", pressed: false) { "B" } }.at_css("input[type=hidden]")
    assert hidden.key?("disabled"), "no unchecked value submits nothing while released"
  end

  test "a single toggle group submits one plain name, with an optional blank first" do
    group = render_ui do
      ToggleGroup(default_value: %w[ left ], name: "align", include_hidden: true, aria_label: "Alignment") { Toggle(value: "left") { "L" } }
    end

    assert_equal [ [ "align", "" ], [ "align", "left" ] ], group.css("input[type=hidden]").map { |input| [ input["name"], input["value"] ] }
    assert_equal "align", group.at_css("[data-slot=toggle-group]")["data-appica-ui--toggle-group-name-value"]
  end
end
