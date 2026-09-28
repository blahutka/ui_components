# Base class for the co-located Lookbook previews (app/components/appica_ui/**/*_preview.rb).
# `phlex { ... }` renders the block as a Phlex view with the AppicaUI and AppicaUI::Blocks kits included, so
# a scenario reads exactly like application code: Autocomplete(items: ...) { ... }
#
# @hidden
class AppicaUI::BasePreview < Lookbook::Preview
  # Text sizes for the em-sized components (Loader, Spinner): `select {{ FONT_SIZES }}` - a
  # YAML list can't hold them, `text-[2.5rem]` would parse as a nested list
  FONT_SIZES = %w[ text-xl text-3xl text-[2.5rem] text-5xl text-7xl ].freeze

  # Currencies for the money blocks' params: `select {{ CURRENCIES }}`
  CURRENCIES = %w[ USD EUR GBP CZK ].freeze

  class Example < AppicaUI::Base
    include AppicaUI::Blocks
    include Phlex::Rails::Helpers::FormWith
    # Phlex::SGML.new keeps a passed block as the content block, so the template is a keyword
    def initialize(template:)
      @template = template
    end

    def view_template
      instance_exec(&@template)
    end

    # The host app's routes (`main_app.users_path`), as in a view - previews render inside Lookbook's engine
    def main_app
      view_context.main_app
    end

    # The props that were filled in: a blank text param falls back to the component's own default
    # (often translated) instead of overriding it with nil -
    #
    #   Transactions(filters:, **given(title:))
    def given(**props)
      props.reject { |_name, value| value.blank? }
    end
  end

  private
    # The choices of a component's `one_of` prop, read from its declaration - for @param tags
    # (Lookbook evaluates `{{ … }}` on the preview instance):
    #
    #   # @param size [Symbol] select {{ choices_for AppicaUI::Button, :size }}
    def choices_for(component, prop)
      component.to_schema.dig("properties", prop.to_s, "enum") ||
        raise(ArgumentError, "#{component}##{prop} is not a one_of prop")
    end

    # Resolved from the top level on every call: Lookbook can hold on to a preview
    # instance from before a code reload, and a lexical `Example` would then point at
    # the unloaded AppicaUI kit, whose component methods (`Button(...)`) no longer exist.
    def phlex(&template)
      render ::AppicaUI::BasePreview::Example.new(template:)
    end
end
