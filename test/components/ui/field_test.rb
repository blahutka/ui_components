require "test_helper"

class UI::FieldTest < ComponentTestCase
  test "wires the label, description and error to the control" do
    field = render_ui do
      Field(id: "email", name: "user[email]", validation_mode: :blur, messages: { value_missing: "Required" }) do
        FieldLabel { "Email" }
        Input(type: "email", required: true)
        FieldDescription { "We'll send your receipt here." }
        FieldError()
      end
    end
    root = field.at_css("[data-slot=field]")
    input = field.at_css("input")
    error = field.at_css("[data-slot=field-error]")

    assert_equal "ui--field", root["data-controller"]
    assert_equal "blur", root["data-ui--field-mode-value"]
    assert_equal({ "valueMissing" => "Required" }, JSON.parse(root["data-ui--field-messages-value"]))
    assert_equal "email-control", field.at_css("label")["for"]
    assert_equal "email-control", input["id"]
    assert_equal "user[email]", input["name"]
    assert_equal "email-description", input["aria-describedby"]
    assert_equal "control", input["data-ui--field-target"]
    assert_equal "email-description", field.at_css("p")["id"]
    assert error["hidden"]
    assert_equal "alert", error["role"]
  end

  test "a server error renders the field invalid with the message" do
    field = render_ui do
      Field(id: "email", error: "has already been taken") do
        Input(start_slot: :mail)
        FieldError()
        FieldError(match: :type_mismatch) { "Not an email" }
      end
    end
    errors = field.css("[data-slot=field-error]")

    assert field.at_css("[data-slot=field][data-invalid]")
    assert field.at_css("[data-slot=input-wrapper][data-invalid]")
    assert_equal "true", field.at_css("input")["aria-invalid"]
    assert_equal "email-description email-error", field.at_css("input")["aria-describedby"]
    assert_nil errors[0]["hidden"]
    assert_equal "has already been taken", errors[0].text
    assert errors[1]["hidden"]
    assert_equal "email-error-type-mismatch", errors[1]["id"]
    assert_equal "typeMismatch", errors[1]["data-match"]
  end

  test "disabled fields disable their control" do
    field = render_ui { Field(disabled: true) { Textarea() } }

    assert field.at_css("[data-slot=field][data-disabled]")
    assert field.at_css("textarea[disabled]")
  end

  test "fieldset labels itself with its legend" do
    fieldset = render_ui { Fieldset(id: "address") { FieldsetLegend { "Shipping address" } } }.at_css("fieldset")

    assert_equal "address-legend", fieldset["aria-labelledby"]
    assert_equal "Shipping address", fieldset.at_css("#address-legend").text
  end
end
