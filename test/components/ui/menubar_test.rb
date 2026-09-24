require "test_helper"

class UI::MenubarTest < ComponentTestCase
  test "renders the bar, menus, triggers and popups with ARIA wiring" do
    html = render_ui do
      Menubar(aria_label: "Application") do
        MenubarMenu(id: "file") do
          MenubarTrigger { "File" }
          MenubarContent do
            MenubarItem { plain "New file"; Kbd(size: :sm, class: "ms-auto") { "⌘N" } }
            MenubarSeparator()
            MenubarItem(disabled: true) { "Save" }
          end
        end
      end
    end

    bar = html.at_css("[role=menubar]")
    assert_equal "ui--menubar", bar["data-controller"]
    assert_equal "Application", bar["aria-label"]
    assert_equal "horizontal", bar["aria-orientation"]

    trigger = html.at_css("[data-slot=menubar-trigger]")
    assert_equal "menuitem", trigger["role"]
    assert_equal "menu", trigger["aria-haspopup"]
    assert_equal "file-content", trigger["aria-controls"]

    content = html.at_css("#file-content")
    assert_equal "menu", content["role"]
    assert content.key?("hidden")
    assert_equal "file-trigger", content["aria-labelledby"]

    items = content.css("[role=menuitem]")
    assert_equal 2, items.size
    assert items.last.key?("data-disabled")
    assert_equal "true", items.first["data-close"]
    assert html.at_css("kbd[data-slot=kbd]")
    assert html.at_css("[role=separator]")
  end

  test "variant, size and orientation" do
    html = render_ui do
      Menubar(variant: :line, size: :lg, orientation: :vertical) do
        MenubarMenu { MenubarTrigger { "Team" } }
      end
    end

    bar = html.at_css("[data-slot=menubar]")
    assert_includes bar["class"], "flex-col"
    assert_equal "vertical", bar["data-orientation"]

    trigger = html.at_css("[data-slot=menubar-trigger]")
    assert_equal "vertical", trigger["data-orientation"]
    assert_includes trigger["class"], "after:bg-no-repeat"
    assert_includes trigger["class"], "text-base"
    assert_includes html.at_css("[data-slot=menubar-menu]")["class"], "flex-col"
  end

  test "checkbox and radio items render their state" do
    html = render_ui do
      Menubar do
        MenubarMenu do
          MenubarTrigger { "View" }
          MenubarContent do
            MenubarGroup do
              MenubarGroupLabel { "Panels" }
              MenubarCheckboxItem(checked: true) { "Toolbar" }
              MenubarCheckboxItem { "Sidebar" }
            end
            MenubarRadioGroup(value: "dark") do
              MenubarGroupLabel { "Theme" }
              MenubarRadioItem(value: "light") { "Light" }
              MenubarRadioItem(value: "dark") { "Dark" }
            end
          end
        end
      end
    end

    toolbar, sidebar = html.css("[role=menuitemcheckbox]")
    assert_equal "true", toolbar["aria-checked"]
    assert toolbar.at_css("[data-slot=menubar-checkbox-item-indicator]").key?("data-checked")
    assert_equal "false", sidebar["aria-checked"]
    assert_equal "false", toolbar["data-close"]

    assert_equal [ "false", "true" ], html.css("[role=menuitemradio]").map { |radio| radio["aria-checked"] }
    group = html.at_css("[data-slot=menubar-group]")
    assert_equal group["aria-labelledby"], group.at_css("[data-slot=menubar-group-label]")["id"]
  end

  test "submenus and link items" do
    html = render_ui do
      Menubar do
        MenubarMenu do
          MenubarTrigger { "File" }
          MenubarContent do
            MenubarSub(id: "recent") do
              MenubarSubTrigger { "Open recent" }
              MenubarSubContent { MenubarItem { "project-alpha" } }
            end
            MenubarLinkItem(href: "/docs") { "Documentation" }
          end
        end
      end
    end

    sub_trigger = html.at_css("[data-slot=menubar-sub-trigger]")
    assert_equal "recent-content", sub_trigger["aria-controls"]
    assert sub_trigger.at_css("svg[data-icon=end]")
    assert html.at_css("#recent-content[role=menu]").key?("hidden")
    assert_equal "/docs", html.at_css("a[data-slot=menubar-link-item]")["href"]
  end

  test "parts outside the bar raise a helpful error" do
    error = assert_raises(ArgumentError) { render_ui { MenubarItem { "Orphan" } } }
    assert_match "must be rendered inside Menubar", error.message
  end
end
