require "test_helper"

class AppicaUI::InputTest < ComponentTestCase
  test "renders a bare input with the variant and size classes and native attributes" do
    input = render_ui { Input(type: "email", variant: :soft, size: :lg, placeholder: "you@example.com", aria_label: "Email", class: "max-w-70") }.at_css("input")

    assert_equal "email", input["type"]
    assert_equal "you@example.com", input["placeholder"]
    assert_equal "Email", input["aria-label"]
    assert_equal "input", input["data-slot"]
    assert_includes input["class"], "bg-background-muted"
    assert_includes input["class"], "h-12"
    assert_includes input["class"], "max-w-70"
  end

  test "an empty placeholder keeps :placeholder-shown usable" do
    assert_equal " ", render_ui { Input() }.at_css("input")["placeholder"]
  end

  test "slots and clearable wrap the input in one frame" do
    wrapper = render_ui { Input(start_slot: :search, end_slot: "kg", clearable: true, value: "Shoes", class: "w-60", input: { class: "font-mono" }) }.at_css("[data-slot=input-wrapper]")
    input = wrapper.at_css("input")

    assert_equal "appica-ui--input", wrapper["data-controller"]
    assert_includes wrapper["class"], "w-60"
    assert wrapper.at_css("[data-slot=input-start] svg")
    assert_equal "kg", wrapper.at_css("[data-slot=input-end]").text
    assert_equal "Shoes", input["value"]
    assert_equal "control", input["data-appica-ui--input-target"]
    assert_includes input["class"], "font-mono"
    assert_equal "Clear input", wrapper.at_css("button[data-slot=input-clear]")["aria-label"]
    assert_equal "Eingabe löschen", I18n.with_locale(:de) { render_ui { Input(clearable: true) }.at_css("[data-slot=input-clear]")["aria-label"] }
  end

  test "invalid and disabled states" do
    invalid = render_ui { Input(invalid: true) }.at_css("input")
    disabled = render_ui { Input(disabled: true, start_slot: :lock) }

    assert_equal "true", invalid["aria-invalid"]
    assert invalid.key?("data-invalid")
    assert disabled.at_css("input[disabled][data-disabled]")
  end

  test "caller attributes replace the defaults instead of joining them" do
    input = render_ui { Input(placeholder: "Search", data: { testid: "q" }) }.at_css("input")

    assert_equal "Search", input["placeholder"]
    assert_equal "q", input["data-testid"]
    assert_equal "input", input["data-slot"]
  end
end
