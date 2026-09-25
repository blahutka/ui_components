require "test_helper"

class UI::NavigationMenuTest < ComponentTestCase
  def render_menu(**options)
    render_ui do
      NavigationMenu(id: "nm", aria_label: "Main", **options) do
        NavigationMenuList do
          NavigationMenuItem(value: "products") do
            NavigationMenuTrigger { plain "Products"; NavigationMenuIcon() }
            NavigationMenuContent { ul { li { NavigationMenuLink(href: "/a") { "Analytics" } } } }
          end
          NavigationMenuItem { NavigationMenuLink(href: "/pricing", active: true) { "Pricing" } }
        end
      end
    end
  end

  test "a nav with triggers wired to hidden, crawlable panels and a shared popup" do
    menu = render_menu
    trigger = menu.at_css("[data-slot=navigation-menu-trigger]")
    content = menu.at_css("[data-slot=navigation-menu-content]")

    assert_equal [ "Main", "ui--navigation-menu" ], menu.at_css("nav").then { |nav| [ nav["aria-label"], nav["data-controller"] ] }
    assert_equal [ "false", "nm-content-products", "nm-trigger-products" ], [ trigger["aria-expanded"], trigger["aria-controls"], trigger["id"] ]
    assert_equal [ "nm-content-products", "nm-trigger-products" ], [ content["id"], content["aria-labelledby"] ]
    assert content.key?("hidden")
    assert_equal "/a", content.at_css("a[data-slot=navigation-menu-link]")["href"]
    assert_equal "vertical", content.at_css("a")["data-orientation"]
    assert_equal "manual", menu.at_css("[data-slot=navigation-menu-popup]")["popover"]
    assert menu.at_css("[data-slot=navigation-menu-popup] > [data-slot=navigation-menu-viewport]")
    bar_link = menu.css("a[data-slot=navigation-menu-link]").last
    assert_equal [ "page", "horizontal", "barLink" ], [ bar_link["aria-current"], bar_link["data-orientation"], bar_link["data-ui--navigation-menu-target"] ]
    assert menu.at_css("[data-slot=navigation-menu-icon] svg")
  end

  test "icons, backdrop, line variant and size" do
    plus = render_menu(icon: :plus, backdrop: true, variant: :line, size: :lg)
    none = render_menu(icon: false)

    assert_equal 2, plus.css("[data-slot=navigation-menu-icon] rect").size
    assert plus.at_css("[data-slot=navigation-menu-backdrop]")
    assert_includes plus.at_css("[data-slot=navigation-menu-trigger]")["class"], "z-50"
    assert_includes plus.at_css("[data-slot=navigation-menu-list]")["class"], "gap-7"
    assert_includes plus.at_css("[data-slot=navigation-menu-popup]")["class"], "rounded-xl"
    assert_nil none.at_css("[data-slot=navigation-menu-icon]")
  end

  test "viewport: false renders no popup and opens default_value; nested menus are submenus" do
    inline = render_menu(viewport: false, default_value: "products")
    nested = render_ui do
      NavigationMenu do
        NavigationMenuItem do
          NavigationMenuContent { NavigationMenu(orientation: :vertical) { NavigationMenuItem { NavigationMenuTrigger { "Handbook" } } } }
        end
      end
    end

    assert_nil inline.at_css("[data-slot=navigation-menu-popup]")
    assert_equal [ "true", "products" ], inline.at_css("nav").then { |nav| [ nav["data-ui--navigation-menu-inline-value"], nav["data-ui--navigation-menu-default-value-value"] ] }
    assert_nil inline.at_css("[data-slot=navigation-menu-content]")["hidden"]
    assert_equal "12", nested.css("nav").last["data-ui--navigation-menu-side-offset-value"]
  end
end
