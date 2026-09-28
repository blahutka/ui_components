require "test_helper"

class AppicaUI::DialogTest < ComponentTestCase
  def render_dialog(component = :Dialog, **options)
    prefix = component.to_s
    render_ui do
      send(prefix, id: "d", **options) do
        send("#{prefix}Trigger") { |trigger| Button(**trigger) { "Open" } }
        send("#{prefix}Content", class: "sm:w-110") do
          send("#{prefix}Header") { send("#{prefix}Title") { "Title" }; send("#{prefix}Description") { "Text" } }
          send("#{prefix}Body") { "Body" }
          send("#{prefix}Footer") { send("#{prefix}Close") { |close| Button(**close) { "Done" } } }
        end
      end
    end
  end

  test "a trigger and a native dialog with a labelled, framed popup and a corner close button" do
    dialog = render_dialog(default_open: true)
    trigger = dialog.at_css("button[data-slot=dialog-trigger]")
    popup = dialog.at_css("[data-slot=dialog-popup]")

    assert_equal [ "appica-ui--dialog", "true", "true" ], dialog.at_css("[data-slot=dialog]").then { |root| [ root["data-controller"], root["data-appica-ui--dialog-open-value"], root["data-appica-ui--dialog-dismissible-value"] ] }
    assert_equal [ "dialog", "false", "d-popup" ], [ trigger["aria-haspopup"], trigger["aria-expanded"], trigger["aria-controls"] ]
    assert dialog.at_css("dialog[data-slot=dialog-viewport] > [data-slot=dialog-backdrop]")
    assert_equal [ "dialog", "d-title", "d-description" ], [ popup["role"], popup["aria-labelledby"], popup["aria-describedby"] ]
    assert popup.key?("data-frame")
    assert_includes popup["class"], "sm:w-110"
    assert_equal "d-title", dialog.at_css("h2[data-slot=dialog-title]")["id"]
    assert_equal "Close", dialog.at_css("[data-slot=dialog-close-button]")["aria-label"]
    assert_equal "appica-ui--dialog#close", dialog.at_css("[data-slot=dialog-footer] button")["data-action"]
  end

  test "frame: false renders a solid card; close_button: false drops the corner button" do
    dialog = render_ui { Dialog { DialogContent(frame: false, close_button: false) { "x" } } }

    assert_nil dialog.at_css("[data-slot=dialog-popup]")["data-frame"]
    assert_includes dialog.at_css("[data-slot=dialog-popup]")["class"], "shadow-2xl"
    assert_nil dialog.at_css("[data-slot=dialog-close-button]")
  end

  test "AlertDialog is an alertdialog without a close button or outside dismissal" do
    dialog = render_dialog(:AlertDialog)
    popup = dialog.at_css("[data-slot=alert-dialog-popup]")

    assert_equal [ "appica-ui--dialog", "false" ], dialog.at_css("[data-slot=alert-dialog]").then { |root| [ root["data-controller"], root["data-appica-ui--dialog-dismissible-value"] ] }
    assert_equal "alertdialog", popup["role"]
    assert_includes popup["class"], "w-100"
    assert_includes dialog.at_css("h2")["class"], "text-xl"
    assert_nil dialog.at_css("[data-slot=alert-dialog-close-button]")
    assert dialog.at_css("[data-slot=alert-dialog-footer] [data-slot=alert-dialog-close]")
  end
end
