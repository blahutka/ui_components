require "test_helper"

class AppicaUI::TabsTest < ComponentTestCase
  def render_tabs(**options)
    render_ui do
      Tabs(id: "t", default_value: "b", **options) do
        TabsList do
          TabsTrigger(value: "a") { "A" }
          TabsTrigger(value: "b") { "B" }
          TabsTrigger(value: "c", disabled: true) { "C" }
        end
        TabsContent(value: "a") { "Panel A" }
        TabsContent(value: "b") { "Panel B" }
      end
    end
  end

  test "wires the tabs pattern and renders the selected tab and panel" do
    tabs = render_tabs
    triggers = tabs.css("[role=tab]")
    panels = tabs.css("[role=tabpanel]")

    assert_equal "appica-ui--tabs", tabs.at_css("[data-slot=tabs]")["data-controller"]
    assert tabs.at_css("[role=tablist] > [data-slot=tabs-indicator][hidden]")
    assert_equal [ "false", "true", "false" ], triggers.map { |trigger| trigger["aria-selected"] }
    assert_equal [ "-1", "0", "-1" ], triggers.map { |trigger| trigger["tabindex"] }
    assert triggers[1].key?("data-active")
    assert triggers[2].key?("disabled")
    assert_equal [ "t-panel-a", "t-tab-a" ], [ triggers[0]["aria-controls"], panels[0]["aria-labelledby"] ]
    assert_equal [ true, false ], panels.map { |panel| panel.key?("hidden") }
    assert_includes tabs.at_css("[role=tablist]")["class"], "bg-background-muted"
  end

  test "line, vertical and size variants; icon triggers" do
    tabs = render_tabs(variant: :line, orientation: :vertical, size: :lg)
    icon = render_ui { Tabs { TabsList { TabsTrigger(value: "g", icon: true, aria_label: "Grid") { "▦" } } } }.at_css("[data-slot=tabs-trigger-inner]")

    assert_equal "vertical", tabs.at_css("[role=tablist]")["aria-orientation"]
    assert_includes tabs.at_css("[role=tablist]")["class"], "data-[orientation=horizontal]:gap-7"
    assert_includes tabs.at_css("[data-slot=tabs-indicator]")["class"], "bg-foreground-intense"
    assert_includes tabs.at_css("[role=tab]")["class"], "text-base"
    assert_includes icon["class"], "size-10"
  end
end
