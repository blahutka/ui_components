require "test_helper"

class AppicaUI::OTPFieldTest < ComponentTestCase
  test "renders a slot per character with the value spread across them" do
    field = render_ui { OTPField(length: 4, default_value: "12", name: "code", aria_label: "Code") { 4.times { |i| OTPFieldInput(aria_label: "Digit #{i + 1}") } } }
    slots = field.css("[data-slot=otp-field-input]")

    assert_equal "group", field.at_css("[data-slot=otp-field]")["role"]
    assert_equal [ "1", "2", nil, nil ], slots.map { |slot| slot["value"] }
    assert_equal [ "one-time-code", "off", "off", "off" ], slots.map { |slot| slot["autocomplete"] }
    assert_equal "numeric", slots.first["inputmode"]
    assert_equal [ "code", "12" ], field.at_css("input.sr-only").then { |input| [ input["name"], input["value"] ] }
    assert_equal "\\d", field.at_css("[data-slot=otp-field]")["data-appica-ui--otp-field-pattern-value"]
  end

  test "mask, separator, alphanumeric and states" do
    field = render_ui { OTPField(length: 2, mask: true, validation_type: :alphanumeric, disabled: true) { OTPFieldInput(); OTPFieldSeparator(); OTPFieldInput() } }

    assert_equal [ "password" ], field.css("[data-slot=otp-field-input]").map { |slot| slot["type"] }.uniq
    assert field.at_css("[data-slot=otp-field-separator][role=separator] svg")
    assert_equal 2, field.css("[data-slot=otp-field-input][disabled]").size
    assert_equal "[A-Za-z0-9]", field.at_css("[data-slot=otp-field]")["data-appica-ui--otp-field-pattern-value"]
  end
end
