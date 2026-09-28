require "test_helper"

class AppicaUI::SelectTest < ComponentTestCase
  def render_select(**options, &items)
    render_ui do
      Select(**options) do
        SelectTrigger(clearable: true, aria_label: "Fruit") { SelectValue(placeholder: "Pick a fruit") }
        SelectContent do
          SelectItem(value: "apple") { "Apple" }
          SelectItem(value: "pear", disabled: true) { "Pear" }
        end
      end
    end
  end

  test "renders a combobox trigger, a popover listbox and the form input" do
    select = render_select(name: "fruit", default_value: "apple", items: { apple: "Apple" }, required: true)
    trigger = select.at_css("[data-slot=select-trigger]")
    content = select.at_css("[data-slot=select-content]")
    list = select.at_css("[role=listbox]")

    assert_equal [ "combobox", "listbox", "false", list["id"] ], %w[ role aria-haspopup aria-expanded aria-controls ].map { |attribute| trigger[attribute] }
    assert_equal "Apple", select.at_css("[data-slot=select-value]").text
    assert_nil trigger["data-placeholder"]
    assert_equal "manual", content["popover"]
    assert_equal [ "true", "false" ], select.css("[role=option]").map { |option| option["aria-selected"] }
    assert select.at_css("[data-value=pear][data-disabled]")
    input = select.at_css("input.sr-only")
    assert_equal [ "fruit", "apple" ], [ input["name"], input["value"] ]
    assert input.key?("required")
    assert_nil select.at_css("[data-slot=select-clear]")["hidden"]
  end

  test "empty shows the placeholder; multiple names each value and summarizes" do
    empty = render_select
    multiple = render_select(multiple: true, name: "fruits", default_value: %w[ apple pear ])

    assert_equal "Pick a fruit", empty.at_css("[data-slot=select-value]").text
    assert empty.at_css("[data-slot=select-trigger][data-placeholder]")
    assert empty.at_css("[data-slot=select-clear][hidden]")
    assert_equal "2 selected", multiple.at_css("[data-slot=select-value]").text
    assert_equal [ "", "apple", "pear" ], multiple.css("input[type=hidden][name='fruits[]']").map { |input| input["value"] }
    assert_equal "true", multiple.at_css("[role=listbox]")["aria-multiselectable"]
  end

  test "inside a Field the trigger mirrors its state and the input validates" do
    field = render_ui do
      Field(id: "fruit", name: "fruit", error: "can't be blank") do
        FieldLabel { "Fruit" }
        Select { SelectTrigger { SelectValue() }; SelectContent { SelectItem(value: "a") { "A" } } }
      end
    end
    trigger = field.at_css("[data-slot=select-trigger]")

    assert_equal [ "fruit-control", "true", "mirror", "fruit-label" ], [ trigger["id"], trigger["aria-invalid"], trigger["data-appica-ui--field-target"], trigger["aria-labelledby"] ]
    assert_equal [ "fruit", "control" ], field.at_css("input.sr-only").then { |input| [ input["name"], input["data-appica-ui--field-target"] ] }
  end
end
