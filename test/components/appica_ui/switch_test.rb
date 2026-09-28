require "test_helper"

class AppicaUI::SwitchTest < ComponentTestCase
  test "renders a checkbox with role switch, sized track and thumb" do
    switch = render_ui { Switch(size: :lg, name: "wifi", checked: true, class: "shadow-xs") }.at_css("[data-slot=switch]")
    input = switch.at_css("input")

    assert_equal "checkbox", input["type"]
    assert_equal "switch", input["role"]
    assert_equal "wifi", input["name"]
    assert input.key?("checked")
    assert_includes input["class"], "h-6 w-11.5"
    assert_includes input["class"], "shadow-xs"
    assert_includes switch.at_css("[data-slot=switch-thumb]")["class"], "size-5"
  end

  test "unchecked_value and invalid" do
    inputs = render_ui { Switch(name: "wifi", value: "1", unchecked_value: "0", invalid: true) }.css("input")

    assert_equal %w[ hidden checkbox ], inputs.map { |input| input["type"] }
    assert_equal "true", inputs.last["aria-invalid"]
  end
end
