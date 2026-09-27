module UiComponents
  # The Lookbook `@param` form of a component's props, generated from its `to_schema`: every
  # preview's `default` ("Usage") scenario lists them all, so each prop can be tried from the
  # Params panel.
  #
  #   bin/rails "ui_components:preview_params[UI::Select]"    # prints tags, signature, call
  #
  # Props that don't fit a form field (Hash / Array / Proc values, generated ids) are left out;
  # a preview names them in UNLISTED_PROPS. test/components/preview_params_test.rb checks that
  # every prop is either a param of the default scenario or unlisted.
  module PreviewParams
    # Untyped props (no default to infer from) that are plain text
    TEXT_PROPS = %w[ name placeholder label title description text alt src href caption value default_value
      placeholder_text close_label clear_label copied_label cover_alt image_alt note ].freeze

    # `given` params are optional text passed through UI::BasePreview#given, so a blank field keeps
    # the component's default (translated labels, computed values) instead of passing nil
    Param = Data.define(:name, :tag, :default, :given) do
      def signature = "#{name}: #{default}"
    end

    class << self
      # [ Param, … ] for the props that fit a form field, in declaration order
      def params(component)
        component.to_schema["properties"].filter_map { |name, schema| param(component, name, schema) }
      end

      # The props left out of the form
      def unlisted(component)
        component.to_schema["properties"].keys - params(component).map(&:name)
      end

      # The component a preview is about: its `@component` tag, else UI::FooPreview → UI::Foo
      def component_for(preview_class)
        file = Object.const_source_location(preview_class.name)&.first
        tagged = file && File.read(file)[/^#\s*@component\s+(\S+)/, 1]
        (tagged || preview_class.name.delete_suffix("Preview")).safe_constantize
      end

      # The keyword pass-through: `variant:, size:, **given(title:)`
      def call_arguments(list)
        direct, given = list.partition { |param| !param.given }
        [ *direct.map { |param| "#{param.name}:" }, ("**given(#{given.map { |param| "#{param.name}:" }.join(", ")})" if given.any?) ].compact.join(", ")
      end

      # The tag block, method signature and keyword pass-through to paste into a preview
      def snippet(component)
        list = params(component)
        [
          *list.map(&:tag),
          "def default(#{list.map(&:signature).join(", ")})",
          "  #{component.name.demodulize}(#{call_arguments(list)})",
          "",
          "# Not in the form: #{unlisted(component).join(", ").presence || "-"}"
        ].join("\n")
      end

      private
        def param(component, name, schema)
          return if name == "id"

          default = schema["default"]
          if schema["enum"]
            Param.new(name, "# @param #{name} [Symbol] select {{ choices_for #{component.name}, :#{name} }}", default ? ":#{default}" : "nil", false)
          elsif schema["type"] == "boolean"
            Param.new(name, "# @param #{name} [Boolean] toggle", default.inspect, false)
          elsif %w[ integer number ].include?(schema["type"])
            Param.new(name, "# @param #{name} number", default.inspect, false)
          elsif schema["type"] == "string" || (schema["type"].nil? && TEXT_PROPS.include?(name))
            if default.nil? || translated?(component, name) || !schema.key?("default")
              Param.new(name, "# @param #{name} text", "nil", true)
            else
              Param.new(name, "# @param #{name} text", default.to_s.inspect, false)
            end
          end
        end

        # A default that changes with the locale (t(".title")) - the preview mustn't freeze it
        def translated?(component, name)
          option = component.dry_initializer.options.find { |candidate| candidate.source.to_s == name }
          return false unless option&.default

          values = I18n.available_locales.first(2).map { |locale| I18n.with_locale(locale) { component.allocate.instance_exec(&option.default) } }
          values.uniq.size > 1
        rescue StandardError
          true
        end
    end
  end
end
