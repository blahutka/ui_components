require "test_helper"

class UI::TextareaTest < ComponentTestCase
  test "renders a textarea with rows, value and size classes" do
    textarea = render_ui { Textarea(rows: 5, size: :sm, value: "Hello", aria_label: "Notes") }.at_css("textarea")

    assert_equal "5", textarea["rows"]
    assert_equal "Hello", textarea.text
    assert_equal "textarea", textarea["data-slot"]
    assert_includes textarea["class"], "resize-y"
  end

  test "slots wrap it and size the frame from the rows" do
    wrapper = render_ui { Textarea(rows: 4, start_slot: :message, clearable: true) }.at_css("[data-slot=textarea-wrapper]")

    assert_includes wrapper["style"], "calc(4 * 1lh"
    assert wrapper.at_css("[data-slot=textarea-start] svg")
    assert wrapper.at_css("textarea[data-ui--input-target=control]")
    assert_equal "Clear input", wrapper.at_css("[data-slot=textarea-clear]")["aria-label"]
  end
end
