require "test_helper"

class AppicaUI::DropdownMenuTest < ComponentTestCase
  def render_menu(**options)
    render_ui do
      DropdownMenu(id: "m", **options) do
        DropdownMenuTrigger { |trigger| Button(**trigger, variant: :outline) { "Open" } }
        DropdownMenuContent(side: :top, align: :end) do
          DropdownMenuGroup do
            DropdownMenuGroupLabel { "Account" }
            DropdownMenuItem(label: "Profile") { "Profile" }
            DropdownMenuItem(disabled: true) { "Billing" }
          end
          DropdownMenuSeparator()
          DropdownMenuCheckboxItem(checked: true) { "Status bar" }
          DropdownMenuRadioGroup(value: "b") do
            DropdownMenuRadioItem(value: "a") { "A" }
            DropdownMenuRadioItem(value: "b") { "B" }
          end
          DropdownMenuLinkItem(href: "/docs") { "Docs" }
          DropdownMenuSub(id: "s") do
            DropdownMenuSubTrigger { "More" }
            DropdownMenuSubContent { DropdownMenuItem { "Deep" } }
          end
        end
      end
    end
  end

  test "a trigger wired to a top-layer menu of items" do
    menu = render_menu(size: :lg)
    trigger = menu.at_css("button")
    content = menu.at_css("[data-slot=dropdown-menu-content]")

    assert_equal "appica-ui--dropdown-menu", menu.at_css("[data-slot=dropdown-menu]")["data-controller"]
    assert_equal [ "m-trigger", "menu", "false", "m-content", "dropdown-menu-trigger" ],
      %w[ id aria-haspopup aria-expanded aria-controls data-slot ].map { |attribute| trigger[attribute] }
    assert_includes trigger["class"], "before:border-border"
    assert_equal [ "manual", "menu", "m-trigger", "top", "end" ], [ content["popover"], content["role"], content["aria-labelledby"], content["data-side"], content["data-align"] ]
    assert_includes content["class"], "rounded-xl"
    assert_equal "Profile", menu.at_css("[role=menuitem][data-label]")["data-label"]
    assert_equal "true", menu.at_css("[data-slot=dropdown-menu-item][data-disabled]")["aria-disabled"]
    assert_includes menu.at_css("[data-slot=dropdown-menu-item]")["class"], "text-base"
  end

  test "checkbox and radio items carry their state; link items and submenus" do
    menu = render_menu

    checkbox = menu.at_css("[role=menuitemcheckbox]")
    assert_equal [ "true", "false" ], [ checkbox["aria-checked"], checkbox["data-close"] ]
    assert checkbox.at_css("[data-slot=dropdown-menu-checkbox-item-indicator][data-checked]")
    assert_equal [ "false", "true" ], menu.css("[role=menuitemradio]").map { |radio| radio["aria-checked"] }
    assert_equal "b", menu.at_css("[data-slot=dropdown-menu-radio-group]")["data-value"]
    assert_equal [ "/docs", "menuitem" ], menu.at_css("a[data-slot=dropdown-menu-link-item]").then { |link| [ link["href"], link["role"] ] }
    sub_trigger = menu.at_css("[data-slot=dropdown-menu-sub-trigger]")
    assert_equal [ "s-content", "menu" ], [ sub_trigger["aria-controls"], sub_trigger["aria-haspopup"] ]
    assert_equal [ "manual", "inline_end" ], menu.at_css("#s-content").then { |sub| [ sub["popover"], sub["data-side"] ] }
  end

  test "open_on_hover and a plain trigger" do
    menu = render_ui { DropdownMenu(open_on_hover: true) { DropdownMenuTrigger { "Open" }; DropdownMenuContent { DropdownMenuItem { "A" } } } }

    assert_equal "true", menu.at_css("[data-slot=dropdown-menu]")["data-appica-ui--dropdown-menu-hover-value"]
    assert_equal "Open", menu.at_css("button[data-slot=dropdown-menu-trigger]").text
  end
end
