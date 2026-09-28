require "test_helper"

class AppicaUI::RadioTest < ComponentTestCase
  test "a group shares its name and checks the default value" do
    group = render_ui do
      RadioGroup(name: "plan", default_value: :pro, required: true, orientation: :horizontal, aria_label: "Plan") do
        Radio(value: "free")
        Radio(value: "pro")
        Radio(value: "team", disabled: true)
      end
    end
    root = group.at_css("[data-slot=radio-group]")
    radios = group.css("input[type=radio]")

    assert_equal "radiogroup", root["role"]
    assert_equal "horizontal", root["aria-orientation"]
    assert_includes root["class"], "flex-row"
    assert_equal [ "plan" ], radios.map { |radio| radio["name"] }.uniq
    assert_equal [ false, true, false ], radios.map { |radio| radio.key?("checked") }
    assert radios.all? { |radio| radio.key?("required") }
    assert radios.last.key?("disabled")
    assert group.at_css("[data-slot=radio-indicator][aria-hidden=true]")
  end

  test "a group without a name generates one; inside a Field it takes the field's" do
    generated = render_ui { RadioGroup { Radio(value: "a") } }.at_css("input")["name"]
    field = render_ui { Field(id: "plan", name: "plan", error: "can't be blank") { RadioGroup { Radio(value: "a"); Radio(value: "b") } } }

    assert_match(/\Aradio-group-\h{8}\z/, generated)
    assert_equal [ "plan" ], field.css("input").map { |radio| radio["name"] }.uniq
    assert_equal [ "true" ], field.css("input").map { |radio| radio["aria-invalid"] }.uniq
    assert_equal [ "control" ], field.css("input").map { |radio| radio["data-appica-ui--field-target"] }.uniq
    assert_equal "plan-description plan-error", field.at_css("[role=radiogroup]")["aria-describedby"]
  end
end
