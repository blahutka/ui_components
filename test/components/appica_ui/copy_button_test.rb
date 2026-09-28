require "test_helper"

class AppicaUI::CopyButtonTest < ComponentTestCase
  test "an icon button carrying the value and labels" do
    button = render_ui { CopyButton(value: "npm i") }.at_css("button")

    assert_equal "copy-button", button["data-slot"]
    assert_equal "appica-ui--copy-button", button["data-controller"]
    assert_equal "npm i", button["data-appica-ui--copy-button-value-value"]
    assert_equal [ "Copy", "Copied" ], [ button["aria-label"], button["data-appica-ui--copy-button-copied-label-value"] ]
    assert_includes button["class"], "size-8"
    assert_includes button["class"], "group/copy"
    assert button.at_css("[role=status]")
  end

  test "a text label, a target element and a custom icon" do
    button = render_ui { CopyButton(target: "#code", icon: :link, size: :md, variant: :outline) { "Copy" } }.at_css("button")

    assert_equal "#code", button["data-appica-ui--copy-button-target-value"]
    assert_equal "Copy", button.at_css("[data-appica-ui--copy-button-target=text]").text
    assert_includes button["class"], "h-10"
    assert button.at_css("svg.appica-icon, svg[data-icon], svg")
    assert_equal "Kopírovat", I18n.with_locale(:cs) { render_ui { CopyButton(value: "x") }.at_css("button")["aria-label"] }
  end
end
