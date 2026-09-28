require "test_helper"

# The Lookbook Params panel: choices come from the components, and every preview's Usage scenario
# lets you try every prop (see UiComponents::PreviewParams)
class PreviewParamsTest < ActiveSupport::TestCase
  PREVIEWS = Lookbook.previews.index_by(&:preview_class)

  # Lookbook silently leaves out a preview it can't load - so do the other tests here
  test "every preview file loads and is in Lookbook" do
    files = Dir[UiComponents::Schema::ROOT.join("**/*_preview.rb")]
    classes = files.filter_map { |file| File.read(file)[/^class (\S+) </, 1] }
    missing = classes.reject { |name| name == "AppicaUI::BasePreview" || PREVIEWS.key?(name.safe_constantize) }

    assert_empty missing, "These previews didn't load - check them with `ruby -c`"
  end

  test "every select param resolves to choices that include its default" do
    broken = scenarios.flat_map do |preview, scenario|
      scenario.tags(:param).select { |tag| tag.input == "select" }.filter_map do |tag|
        choices = Array(tag.options.to_h[:choices]).map(&:to_s)
        default = tag.value_default
        next "#{preview.preview_class}##{scenario.name} @param #{tag.name}: no choices" if choices.empty?
        next if default.nil? || choices.include?(default.to_s)

        "#{preview.preview_class}##{scenario.name} @param #{tag.name}: default #{default.inspect} isn't one of #{choices.inspect}"
      end
    end

    assert_empty broken
  end

  test "each Usage scenario lists every prop of its component, or names it in UNLISTED_PROPS" do
    missing = PREVIEWS.filter_map do |preview_class, preview|
      component = UiComponents::PreviewParams.component_for(preview_class)
      default = preview.scenarios.find { |scenario| scenario.name.to_s == "default" }
      next unless component.is_a?(Class) && component < AppicaUI::Base && default

      listed = default.tags(:param).map(&:name)
      unlisted = preview_class.const_defined?(:UNLISTED_PROPS, false) ? preview_class::UNLISTED_PROPS.map(&:to_s) : []
      props = component.to_schema["properties"].keys - listed - unlisted
      "#{preview_class}: #{props.join(", ")}  (bin/rails \"ui_components:preview_params[#{component}]\")" if props.any?
    end

    assert_empty missing, "Add these props to the Usage scenario's @params, or to UNLISTED_PROPS with a reason"
  end

  test "every Usage scenario renders with its default params" do
    failures = PREVIEWS.filter_map do |preview_class, _preview|
      next unless preview_class.method_defined?(:default)

      result = preview_class.new.default
      component = result.is_a?(Hash) ? result[:component] : nil
      ApplicationController.renderer.render(component, layout: false) if component
      nil
    rescue StandardError => error
      "#{preview_class}#default: #{error.class}: #{error.message.lines.first}"
    end

    assert_empty failures
  end

  private
    def scenarios
      PREVIEWS.values.flat_map do |preview|
        preview.scenarios.flat_map { |entry| entry.respond_to?(:source) ? [ entry ] : entry.scenarios.to_a }.map { |scenario| [ preview, scenario ] }
      end
    end
end
