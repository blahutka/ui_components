require "test_helper"

class AppicaUI::ToastTest < ComponentTestCase
  test "toaster renders six viewports, server toasts and templates" do
    html = render_ui { Toaster(progress: true, toasts: [ { title: "Signed in", icon: :success } ]) }

    root = html.at_css("[data-slot=toaster]")
    assert_equal "appica-ui--toaster", root["data-controller"]
    assert_equal "bottom-right", root["data-appica-ui--toaster-position-value"]

    viewports = html.css("[data-slot=toast-viewport]")
    assert_equal 6, viewports.size
    default = html.at_css("#toaster")
    assert_equal "bottom-right", default["data-position"]
    assert_equal "polite", default["aria-live"]

    toast = default.at_css("> [data-slot=toast]")
    assert_equal "Signed in", toast.at_css("[data-slot=toast-title]").text
    assert_equal "bottom", toast["data-side"]
    assert toast.at_css("[data-slot=toast-icon] svg")
    assert toast.at_css("[data-slot=toast-progress-indicator]")["style"].include?("5000ms")

    assert html.at_css("template[data-appica-ui--toaster-target=template]")
    assert_equal 12, html.css("template[data-appica-ui--toaster-target=iconTemplate]").size
  end

  test "toast options" do
    html = render_ui do
      Toaster(position: :top_center) do
        Toast(title: "Upload failed", description: "Too big.", icon: :error, thumbnail: true, priority: :high, timeout: 0,
              action: { label: "Retry", event: "upload:retry" })
      end
    end

    toast = html.at_css("[data-slot=toast]")
    assert_equal "alert", toast["role"]
    assert_equal "top", toast["data-side"]
    assert_equal "0", toast["data-timeout"]
    assert_equal toast["aria-describedby"], toast.at_css("[data-slot=toast-description]")["id"]
    assert toast.at_css("[data-slot=toast-thumbnail]")
    assert_equal "upload:retry", toast.at_css("[data-slot=toast-action]")["data-event"]
    assert_nil toast.at_css("[data-slot=toast-progress]")
  end

  test "a standalone toast (Turbo Stream) renders without a toaster" do
    toast = render_ui { Toast(title: "Saved", dismissible: false) }.at_css("[data-slot=toast]")

    assert_equal "pointerdown->appica-ui--toaster#swipeStart", toast["data-action"]
    assert_nil toast["data-side"], "the toaster sets the side when the toast arrives"
    assert_nil toast.at_css("[data-slot=toast-close]")
    assert_includes toast["class"], "[--sign:-1]"
  end

  test "toast trigger serializes camelCased options" do
    button = render_ui do
      ToastTrigger(toast: { title: "Archived", action: { label: "Undo", toast: { title: "Restored" } }, position: "top-left" }) { |trigger| Button(**trigger) { "Archive" } }
    end.at_css("button")

    options = JSON.parse(button["data-toast"])
    assert_equal "Archived", options["title"]
    assert_equal "Restored", options.dig("action", "toast", "title")
    assert_equal "top-left", options["position"]
  end
end
