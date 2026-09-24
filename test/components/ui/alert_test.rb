require "test_helper"

class UI::AlertTest < ComponentTestCase
  test "renders a role=alert grid inside the animated container" do
    html = render_ui do
      Alert do
        AlertIcon { "!" }
        AlertTitle { "Heads up" }
        AlertDescription { "Refresh to update." }
      end
    end
    box = html.at_css("[data-controller=ui--alert]")
    alert = box.at_css("[data-slot=alert]")

    assert_includes box["class"], "@container"
    assert_equal "alert", alert["role"]
    assert_equal "block", alert["data-layout"]
    assert_includes alert["class"], "bg-background border-border"
    assert_includes html.at_css("[data-slot=alert-icon]")["class"], "text-foreground-intense"
    assert_equal "h5", html.at_css("[data-slot=alert-title]").name
    assert_equal "p", html.at_css("[data-slot=alert-description]").name
    assert_nil html.at_css("[data-slot=alert-close]")
  end

  test "the variant colors the surface and the icon" do
    html = render_ui { Alert(variant: :warning, layout: :inline) { AlertIcon { "!" } } }

    assert_includes html.at_css("[data-slot=alert]")["class"], "bg-warning-subtle border-warning-soft"
    assert_equal "inline", html.at_css("[data-slot=alert]")["data-layout"]
    assert_includes html.at_css("[data-slot=alert-icon]")["class"], "text-warning-emphasis"
  end

  test "dismissible adds a labelled close button wired to the controller" do
    close = render_ui { Alert(dismissible: true, close_label: "Close banner") { AlertTitle { "Saved" } } }.at_css("[data-slot=alert-close]")

    assert_equal "Close banner", close["aria-label"]
    assert_equal "ui--alert#dismiss", close["data-action"]
  end

  test "open: false renders hidden and persist_key is handed to the controller" do
    box = render_ui { Alert(open: false, persist_key: "trial", persist_storage: :session) { AlertTitle { "Hi" } } }.at_css("[data-controller=ui--alert]")

    assert box.key?("hidden")
    assert_equal "false", box["data-ui--alert-open-value"]
    assert_equal "trial", box["data-ui--alert-persist-key-value"]
    assert_equal "session", box["data-ui--alert-persist-storage-value"]
  end

  test "title level and actions" do
    html = render_ui do
      Alert do
        AlertTitle(as: :h3) { "Title" }
        AlertAction { Button(size: :sm) { "Upgrade" } }
      end
    end

    assert_equal "h3", html.at_css("[data-slot=alert-title]").name
    assert_equal "Upgrade", html.at_css("[data-slot=alert-action] button").text
  end
end
