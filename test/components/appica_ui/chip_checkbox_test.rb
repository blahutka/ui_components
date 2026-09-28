require "test_helper"

class AppicaUI::ChipCheckboxTest < ComponentTestCase
  test "a selectable chip is a label around a hidden checkbox" do
    chip = render_ui { ChipCheckbox(name: "tags[]", value: "ruby", checked: true) { "Ruby" } }.at_css("label[data-slot=chip-checkbox]")

    input = chip.at_css("input[type=checkbox]")
    assert_equal [ "tags[]", "ruby" ], [ input["name"], input["value"] ]
    assert input.key?("checked")
    assert_includes input["class"], "sr-only"
    assert_equal [ "outline", "md", "Ruby" ], [ chip["data-variant"], chip["data-size"], chip.text.strip ]
  end

  test "inside a ChipGroup it takes the group's variant and size" do
    chip = render_ui { ChipGroup(variant: :soft, size: :sm) { ChipCheckbox(value: "a", disabled: true) { "A" } } }.at_css("[data-slot=chip-checkbox]")

    assert_equal [ "soft", "sm" ], [ chip["data-variant"], chip["data-size"] ]
    assert chip.at_css("input").key?("disabled")
  end
end
