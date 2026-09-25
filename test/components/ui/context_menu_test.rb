require "test_helper"

class UI::ContextMenuTest < ComponentTestCase
  test "a trigger area and DropdownMenu's parts under the context-menu names" do
    menu = render_ui do
      ContextMenu(id: "c") do
        ContextMenuTrigger(class: "h-40") { "Right-click here" }
        ContextMenuContent do
          ContextMenuItem { "Copy" }
          ContextMenuCheckboxItem(checked: true) { "Rulers" }
          ContextMenuSub { ContextMenuSubTrigger { "Move to" }; ContextMenuSubContent { ContextMenuItem { "Archive" } } }
        end
      end
    end
    trigger = menu.at_css("div[data-slot=context-menu-trigger]")

    assert_equal "ui--context-menu", menu.at_css("[data-slot=context-menu]")["data-controller"]
    assert_includes trigger["data-action"], "contextmenu->ui--context-menu#openAtPointer"
    assert_includes trigger["class"], "h-40"
    content = menu.at_css("[data-slot=context-menu-content]")
    assert_equal [ "manual", "2", "c-content" ], [ content["popover"], content["data-side-offset"], content["id"] ]
    assert menu.at_css("[data-slot=context-menu-item][role=menuitem]")
    assert menu.at_css("[data-slot=context-menu-checkbox-item][aria-checked=true]")
    assert menu.at_css("[data-slot=context-menu-sub-trigger]")
  end
end
