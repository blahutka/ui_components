require "test_helper"

class AppicaUI::ButtonGroupTest < ComponentTestCase
  test "shares variant, size and icon with its buttons; a button's own wins" do
    group = render_ui do
      ButtonGroup(variant: :outline, size: :sm, aria_label: "Range") do
        Button { "Years" }
        Button(variant: :primary) { "Days" }
      end
    end
    root = group.at_css("[data-slot=button-group]")
    years, days = group.css("button")

    assert_equal "group", root["role"]
    assert_includes root["class"], "-space-x-(--border-width)"
    assert_includes years["class"], "before:border-border"
    assert_includes years["class"], "h-8"
    assert_includes days["class"], "bg-primary"
    assert_includes days["class"], "h-8"
  end

  test "filled variants keep a gap, vertical groups square the other corners, disabled wins" do
    group = render_ui { ButtonGroup(orientation: :vertical, disabled: true) { Button { "A" } } }
    root = group.at_css("[data-slot=button-group]")

    assert_includes root["class"], "flex-col"
    assert_includes root["class"], "space-y-(--border-width)"
    assert group.at_css("button[disabled][data-disabled]")
  end

  test "a lone button keeps its defaults" do
    classes = render_ui { Button { "Save" } }.at_css("button")["class"]

    assert_includes classes, "bg-primary"
    assert_includes classes, "h-10"
  end
end
