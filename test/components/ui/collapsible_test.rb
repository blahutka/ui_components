require "test_helper"

class UI::CollapsibleTest < ComponentTestCase
  test "renders a closed disclosure with ARIA wiring" do
    html = render_ui do
      Collapsible(id: "plan") do
        CollapsibleTrigger { "What's included?" }
        CollapsibleContent { "Three projects." }
      end
    end

    root = html.at_css("[data-slot=collapsible]")
    assert_equal "ui--collapsible", root["data-controller"]
    assert root.key?("data-closed")
    assert_equal "false", root["data-ui--collapsible-open-value"]

    trigger = html.at_css("button[data-slot=collapsible-trigger]")
    assert_equal "false", trigger["aria-expanded"]
    assert_equal "plan-content", trigger["aria-controls"]
    assert_not trigger.key?("data-panel-open")

    content = html.at_css("#plan-content")
    assert content.key?("hidden")
    assert_includes content["class"], "h-(--collapsible-panel-height)"
  end

  test "open state is rendered on the server" do
    html = render_ui do
      Collapsible(open: true) do
        CollapsibleTrigger { "Open" }
        CollapsibleContent { "Visible" }
      end
    end

    assert html.at_css("[data-slot=collapsible]").key?("data-open")
    assert html.at_css("[data-slot=collapsible-trigger]").key?("data-panel-open")
    assert_not html.at_css("[data-slot=collapsible-content]").key?("hidden")
  end

  test "disabled triggers leave the tab order" do
    trigger = render_ui { Collapsible(disabled: true) { CollapsibleTrigger { "Locked" } } }.at_css("[data-slot=collapsible-trigger]")

    assert_equal "-1", trigger["tabindex"]
    assert_equal "true", trigger["aria-disabled"]
    assert trigger.key?("data-disabled")
  end

  test "the trigger can render through a Button" do
    button = render_ui do
      Collapsible { CollapsibleTrigger { |trigger| Button(**trigger, variant: :outline, icon: true, aria_label: "More") { "+" } } }
    end.at_css("button")

    assert_equal "collapsible-trigger", button["data-slot"]
    assert_equal "ui--collapsible#toggle", button["data-action"]
    assert_includes button["class"], "before:border-border"
  end

  test "hidden until found" do
    content = render_ui { Collapsible { CollapsibleContent(hidden_until_found: true) { "Findable" } } }.at_css("[data-slot=collapsible-content]")

    assert_equal "until-found", content["hidden"]
  end
end
