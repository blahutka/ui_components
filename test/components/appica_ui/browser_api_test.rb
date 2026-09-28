require "test_helper"

class AppicaUI::BrowserAPITest < ActiveSupport::TestCase
  COMPONENTS_PATH = UiComponents::Engine::COMPONENTS_PATH

  test "importmap and dummy app load the appica_ui entrypoints" do
    importmap = File.read(UiComponents::Engine.root.join("config/importmap.rb"))
    application = File.read(Rails.root.join("app/javascript/application.js"))
    stylesheet = File.read(Rails.root.join("app/assets/tailwind/application.css"))

    assert_includes importmap, 'under: "appica_ui", to: "appica_ui"'
    assert_includes application, 'import "appica_ui"'
    assert_includes application, 'import "appica_ui/blocks"'
    assert_includes stylesheet, "app/components/appica_ui/index.css"
    assert_not_includes importmap, 'under: "ui"'
    assert_not_includes application, 'import "ui"'
    assert_not_includes application, 'import "blocks"'
  end

  test "entrypoints register the renamed primitive and block controllers" do
    primitives = File.read(COMPONENTS_PATH.join("appica_ui/index.js"))
    blocks = File.read(COMPONENTS_PATH.join("appica_ui/blocks/index.js"))

    assert_includes primitives, 'from "appica_ui/select/select_controller"'
    assert_includes primitives, 'application.register("appica-ui--select", SelectController)'
    assert_includes blocks, 'from "appica_ui/blocks/transactions/transactions_controller"'
    assert_includes blocks, 'application.register("appica-ui--blocks--transactions", TransactionsController)'
    assert_not_includes primitives, 'application.register("ui--'
    assert_not_includes blocks, 'application.register("blocks--'
  end

  test "toast is exposed only through window AppicaUI" do
    toast = File.read(COMPONENTS_PATH.join("appica_ui/toast/toast.js"))

    assert_includes toast, "window.AppicaUI = window.AppicaUI || {}"
    assert_includes toast, "window.AppicaUI.toast = toast"
    assert_not_includes toast, "window.UI"
  end
end
