require "test_helper"

class Blocks::CommandMenuTest < ComponentTestCase
  test "renders the search, grouped commands with shortcuts and key hints" do
    html = render_ui do
      CommandMenu do
        CommandGroup(label: "Suggestions") do
          CommandItem(icon: :layout_dashboard, shortcut: %w[ G D ], href: "/dashboard") { "Open dashboard" }
          CommandItem(icon: :rocket, shortcut: %w[ ⇧ D ], value: "deploy") { "Deploy to production" }
        end
      end
    end

    menu = html.at_css("[data-slot=command-menu]")
    assert_equal [ "blocks--command-menu", "k" ], [ menu["data-controller"], menu["data-blocks--command-menu-hotkey-value"] ]
    input = menu.at_css("input[data-blocks--command-menu-target=input]")
    assert_equal [ "Search or jump to…", "Search commands" ], [ input["placeholder"], input["aria-label"] ]
    assert_equal "⌘K", menu.at_css("[data-slot=input-end] [data-slot=kbd]").text
    assert_equal "Command results", menu.at_css("nav")["aria-label"]
    assert_equal "Suggestions", menu.at_css("[data-slot=command-group-label]").text

    link, button = menu.css("[data-slot=command-item]")
    assert_equal [ "a", "/dashboard", "Open dashboard" ], [ link.name, link["href"], link.at_css("[data-slot=command-item-label]").text ]
    assert_equal %w[ G D ], link.css("[data-slot=kbd]").map(&:text)
    assert_equal [ "button", "deploy" ], [ button.name, button["data-value"] ]
    assert_nil link["aria-current"]
    assert menu.at_css("[data-slot=command-menu-empty][hidden]")
    assert_equal %w[ ↑ ↓ ↵ ], menu.css("[data-slot=command-menu-hints] [data-slot=kbd]").map(&:text)
  end

  test "hints and the hotkey hint can be dropped" do
    html = render_ui { CommandMenu(hints: false, hotkey_hint: nil) { CommandGroup { CommandItem { "Home" } } } }

    assert_nil html.at_css("[data-slot=command-menu-hints]")
    assert_nil html.at_css("[data-slot=input-end]")
    assert_nil html.at_css("[data-slot=command-group-label]")
  end
end
