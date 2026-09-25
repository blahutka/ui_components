require "test_helper"

class UI::NumberFieldTest < ComponentTestCase
  test "keeps invalid text in the visible and submitted value" do
    field = render_ui { NumberField(value: "abc", name: "age", min: 18, max: 120, step: 1) }
    input = field.at_css("[data-slot=number-field-input]")

    assert_equal "abc", input["value"]
    assert_nil input["aria-valuenow"]
    assert_equal "abc", field.at_css("input[type=hidden]")["value"]
    assert_equal [ "18", "120", "1" ], %w[ min max step ].map { |key| input[key] }
  end

  test "empty value submits an empty string" do
    field = render_ui { NumberField(value: "", name: "age") }

    assert_equal "", field.at_css("input[type=hidden]")["value"]
    assert_nil field.at_css("[data-slot=number-field-input]")["aria-valuenow"]
  end

  test "renders steppers around a spinbutton and a hidden plain value" do
    field = render_ui { NumberField(default_value: 10, min: 0, max: 10, name: "quantity", aria_label: "Quantity") }
    input = field.at_css("[data-slot=number-field-input]")

    assert_equal "ui--number-field", field.at_css("[data-slot=number-field]")["data-controller"]
    assert_equal [ "spinbutton", "10", "10", "0", "10", "Quantity" ], %w[ role value aria-valuenow aria-valuemin aria-valuemax aria-label ].map { |attribute| input[attribute] }
    assert_nil input["name"]
    assert_equal "10", field.at_css("input[type=hidden][name=quantity]")["value"]
    assert field.at_css("[data-slot=number-field-increment][disabled]"), "at the max"
    assert_nil field.at_css("[data-slot=number-field-decrement]")["disabled"]
    assert_equal input["id"], field.at_css("[data-slot=number-field-increment]")["aria-controls"]
    assert_equal "Increase value", field.at_css("[data-slot=number-field-increment]")["aria-label"]
  end

  test "formats the display and defaults the large / small steps from the step" do
    field = render_ui { NumberField(default_value: 19.99, step: 0.5, format: { style: "currency", currency: "USD" }) }
    root = field.at_css("[data-slot=number-field]")

    assert_equal "$19.99", field.at_css("input")["value"]
    assert_equal "$19.99", field.at_css("input")["aria-valuetext"]
    assert_equal [ "0.5", "5", "0.05" ], %w[ step large-step small-step ].map { |key| root["data-ui--number-field-#{key}-value"] }
  end

  test "size, variant, invalid and a Field" do
    field = render_ui { Field(id: "qty", name: "qty", error: "is too big") { NumberField(size: :lg, variant: :soft) } }

    assert_includes field.at_css("[data-slot=number-field]")["class"], "w-35"
    assert_equal "qty-control", field.at_css("[data-slot=number-field-input]")["id"]
    assert_equal "true", field.at_css("[data-slot=number-field-input]")["aria-invalid"]
    assert field.at_css("input[type=hidden][name=qty]")
  end
end
