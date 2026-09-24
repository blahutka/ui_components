require "test_helper"

class UI::DrawerTest < ComponentTestCase
  test "renders the compound structure on a native dialog" do
    html = render_ui do
      Drawer(side: :right, id: "notifications") do
        DrawerTrigger { |trigger| Button(**trigger, variant: :outline) { "Open drawer" } }
        DrawerContent do
          DrawerHeader do
            DrawerTitle { "Notifications" }
            DrawerDescription { "Choose what you want to be notified about." }
          end
          DrawerBody { "Body" }
          DrawerFooter do
            DrawerClose { |close| Button(**close) { "Save" } }
          end
        end
      end
    end

    root = html.at_css("[data-slot=drawer]")
    assert_equal "ui--drawer", root["data-controller"]
    assert_equal "right", root["data-ui--drawer-side-value"]

    trigger = html.at_css("[data-slot=drawer-trigger]")
    assert_equal "BUTTON", trigger.name.upcase
    assert_equal "ui--drawer#open", trigger["data-action"]
    assert_equal "notifications-dialog", trigger["aria-controls"]
    assert_includes trigger["class"], "before:border-border"

    dialog = html.at_css("dialog[data-slot=drawer-viewport]")
    assert_equal "notifications-dialog", dialog["id"]
    assert_includes dialog["class"], "justify-end"
    assert_equal "notifications-title", dialog["aria-labelledby"]
    assert_equal "Notifications", html.at_css("h2#notifications-title").text
    assert_equal "notifications-description", html.at_css("p[data-slot=drawer-description]")["id"]

    assert html.at_css("[data-slot=drawer-backdrop]")
    popup = html.at_css("[data-slot=drawer-popup]")
    assert popup.key?("data-frame")
    assert_includes popup["class"], "w-96"

    assert_equal "ui--drawer#close", html.at_css("[data-slot=drawer-close]")["data-action"]
    assert_equal "Close", html.at_css("[data-slot=drawer-close-button]")["aria-label"]
  end

  test "side switches the panel geometry" do
    html = render_ui do
      Drawer(side: :bottom, snap_points: [ 0.4, 1 ]) do
        DrawerContent(class: "mx-auto max-w-2xl") { DrawerTitle { "Sheet" } }
      end
    end

    assert_equal "[0.4,1]", html.at_css("[data-slot=drawer]")["data-ui--drawer-snap-points-value"]
    assert_includes html.at_css("dialog")["class"], "items-end"

    popup = html.at_css("[data-slot=drawer-popup]")["class"]
    assert_includes popup, "origin-bottom"
    assert_includes popup, "max-w-2xl"
  end

  test "false options are rendered explicitly for Stimulus" do
    root = render_ui { Drawer(modal: false, disable_pointer_dismissal: true) { } }.at_css("[data-slot=drawer]")

    assert_equal "false", root["data-ui--drawer-modal-value"]
    assert_equal "false", root["data-ui--drawer-dismissible-value"]
  end

  test "nested drawers render without a backdrop as a solid card" do
    html = render_ui do
      Drawer(side: :right) do
        DrawerContent do
          DrawerBody do
            Drawer(side: :right) do
              DrawerContent(close_button: false) { DrawerTitle { "Child" } }
            end
          end
        end
      end
    end

    popups = html.css("[data-slot=drawer-popup]")
    assert_equal 1, html.css("[data-slot=drawer-backdrop]").size
    assert popups.first.key?("data-frame")
    assert_not popups.last.key?("data-frame")
    assert popups.last.key?("data-nested")
    assert_equal 1, html.css("[data-slot=drawer-close-button]").size
  end

  test "trigger and close render plain buttons without a render block" do
    html = render_ui do
      Drawer do
        DrawerTrigger(class: "underline") { "Open" }
        DrawerContent(close_button: false) { DrawerClose { "Done" } }
      end
    end

    assert_equal "underline", html.at_css("button[data-slot=drawer-trigger]")["class"]
    assert_equal "Done", html.at_css("button[data-slot=drawer-close]").text
  end

  test "parts outside the root raise a helpful error" do
    error = assert_raises(ArgumentError) { render_ui { DrawerTitle { "Orphan" } } }
    assert_match "must be rendered inside Drawer", error.message
  end
end
