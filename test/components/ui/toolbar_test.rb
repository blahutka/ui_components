require "test_helper"

class UI::ToolbarTest < ComponentTestCase
  test "items hand their attributes to the controls they wrap" do
    toolbar = render_ui do
      Toolbar(aria_label: "Formatting") do
        ToolbarGroup(aria_label: "Style", disabled: true) do
          ToolbarButton { |item| Button(**item, variant: :ghost) { "Bold" } }
        end
        ToolbarSeparator()
        ToolbarLink(href: "#help") { "Help" }
        ToolbarInput { |item| Input(**item, placeholder: "Search") }
      end
    end
    root = toolbar.at_css("[data-slot=toolbar]")
    button = toolbar.at_css("button")

    assert_equal [ "toolbar", "horizontal", "ui--toolbar" ], [ root["role"], root["aria-orientation"], root["data-controller"] ]
    assert_equal [ "toolbar-button", "item", "-1", "true" ], [ button["data-slot"], button["data-ui--toolbar-target"], button["tabindex"], button["aria-disabled"] ]
    assert_includes button["class"], "hover:before:bg-background-muted"
    assert_equal "vertical", toolbar.at_css("[data-slot=toolbar-separator]")["data-orientation"]
    assert_equal "#help", toolbar.at_css("a[data-slot=toolbar-link]")["href"]
    assert_equal "item", toolbar.at_css("input[placeholder=Search]")["data-ui--toolbar-target"]
  end

  test "a vertical toolbar flips its separators" do
    toolbar = render_ui { Toolbar(orientation: :vertical) { ToolbarButton { "A" }; ToolbarSeparator() } }

    assert_equal "vertical", toolbar.at_css("[data-slot=toolbar]")["data-orientation"]
    assert_equal "horizontal", toolbar.at_css("[data-slot=toolbar-separator]")["aria-orientation"]
    assert_equal "toolbar-button", toolbar.at_css("button")["data-slot"]
  end
end
