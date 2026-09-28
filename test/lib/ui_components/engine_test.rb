require "test_helper"

class UiComponents::EngineTest < ActiveSupport::TestCase
  # Just enough of an application's configuration for the two switches to read.
  Config = Struct.new(:ui_components, :importmap) do
    def respond_to?(name, include_private = false)
      name == :importmap ? !importmap.nil? : super
    end
  end
  App = Struct.new(:config)

  test "pins the component JavaScript into a Propshaft host with importmap" do
    assert UiComponents::Engine.importmap?(app(importmap: :auto))
  end

  # Sprockets hosts would be handed pins for assets they never precompiled.
  test "leaves a host without Propshaft alone unless it asks" do
    hide_const(:Propshaft) do
      assert_not UiComponents::Engine.importmap?(app(importmap: :auto))
      assert UiComponents::Engine.importmap?(app(importmap: true))
    end
  end

  test "never pins into a host without importmap, whatever the setting says" do
    assert_not UiComponents::Engine.importmap?(app(importmap: true, host_importmap: nil))
  end

  test "a host can turn the pins off" do
    assert_not UiComponents::Engine.importmap?(app(importmap: false))
  end

  # A host with its own Lookbook must not inherit this gem's previews by accident.
  test "registers previews only when the host opts in" do
    assert_not UiComponents::Engine.lookbook?(app(lookbook: false))
    assert_equal defined?(Lookbook).present?, UiComponents::Engine.lookbook?(app(lookbook: true))
  end

  private
    def app(importmap: :auto, lookbook: false, host_importmap: Object.new)
      settings = ActiveSupport::OrderedOptions.new
      settings.importmap = importmap
      settings.lookbook = lookbook

      App.new(Config.new(settings, host_importmap))
    end

    def hide_const(name)
      value = Object.send(:remove_const, name) if Object.const_defined?(name)
      yield
    ensure
      Object.const_set(name, value) if value
    end
end
