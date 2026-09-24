require "test_helper"

class UI::ButtonTest < ComponentTestCase
  test "renders a primary md button by default" do
    button = render_ui { Button { "Save" } }.at_css("button")

    assert_equal "button", button["type"]
    assert_equal "button", button["data-slot"]
    assert_includes button["class"], "bg-primary"
    assert_includes button["class"], "h-10"
    assert_equal "Save", button.text
  end

  test "variant, size and icon switch the classes" do
    classes = render_ui { Button(variant: :outline, size: :sm, icon: true, aria_label: "Close") { "×" } }.at_css("button")["class"]

    assert_includes classes, "before:border-border"
    assert_includes classes, "size-8"
    assert_not_includes classes, "px-4"
  end

  test "renders a link with href" do
    link = render_ui { Button(href: "/docs") { "Docs" } }.at_css("a")

    assert_equal "/docs", link["href"]
    assert_nil link["type"]
  end

  test "keeps the slot of a part projected onto it" do
    button = render_ui { Button(data: { slot: "drawer-close" }) { "Close" } }.at_css("button")

    assert_equal "drawer-close", button["data-slot"]
  end
end
