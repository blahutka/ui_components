require "test_helper"

class UI::CheckboxTest < ComponentTestCase
  test "renders a native checkbox with the indicator" do
    box = render_ui { Checkbox(name: "terms", checked: true, required: true, class: "mt-1") }.at_css("[data-slot=checkbox]")
    input = box.at_css("input[type=checkbox]")

    assert_includes box["class"], "mt-1"
    assert_equal "terms", input["name"]
    assert input.key?("checked")
    assert input.key?("required")
    assert box.at_css("svg[data-slot=checkbox-indicator][aria-hidden=true] path")
  end

  test "indeterminate is set by a controller; invalid is normalized to aria-invalid=true" do
    indeterminate = render_ui { Checkbox(indeterminate: true) }.at_css("input")
    invalid = render_ui { Checkbox(aria_invalid: true) }.at_css("input")

    assert_equal "ui--checkbox", indeterminate["data-controller"]
    assert indeterminate.key?("data-indeterminate")
    assert_equal "true", invalid["aria-invalid"]
  end

  test "unchecked_value submits a hidden fallback first" do
    inputs = render_ui { Checkbox(name: "newsletter", value: "1", unchecked_value: "0") }.css("input")

    assert_equal [ %w[ hidden 0 ], %w[ checkbox 1 ] ], inputs.map { |input| [ input["type"], input["value"] ] }
    assert_equal [ "newsletter" ], inputs.map { |input| input["name"] }.uniq
  end

  test "a group names its boxes, checks its values and wires a parent" do
    group = render_ui do
      CheckboxGroup(name: "toppings[]", default_value: %i[ cheese ], disabled: true, aria_label: "Toppings") do
        Checkbox(parent: true)
        Checkbox(value: "cheese")
        Checkbox(value: "olives")
      end
    end
    root = group.at_css("[data-slot=checkbox-group]")
    parent, cheese, olives = group.css("input")

    assert_equal "group", root["role"]
    assert_equal "ui--checkbox-group", root["data-controller"]
    assert_nil parent["name"]
    assert_equal "parent", parent["data-ui--checkbox-group-target"]
    assert_equal "ui--checkbox-group#toggleAll", parent["data-action"]
    assert_equal [ "toppings[]", "toppings[]" ], [ cheese["name"], olives["name"] ]
    assert cheese.key?("checked")
    assert_not olives.key?("checked")
    assert olives.key?("disabled")
  end

  test "inside a Field it takes the field's id, name and state" do
    input = render_ui { Field(id: "terms", name: "terms", error: "must be accepted") { Checkbox() } }.at_css("input")

    assert_equal "terms-control", input["id"]
    assert_equal "terms", input["name"]
    assert_equal "true", input["aria-invalid"]
    assert_equal "control", input["data-ui--field-target"]
  end
end
