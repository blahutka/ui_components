require_relative "form_builder_extension"

module UiComponents
  class Engine < ::Rails::Engine
    COMPONENTS_PATH = root.join("app/components")

    # Sidecar layout: app/components/ui/<component>/{*.rb,*_controller.js,*.css}.
    # Collapsing the component folders keeps constants flat (UI::AutocompleteInput),
    # like the React exports, instead of UI::Autocomplete::AutocompleteInput.
    initializer "ui_components.autoloader", before: :setup_main_autoloader do
      Rails.autoloaders.main.inflector.inflect(
        "ui" => "UI",
        "otp_field" => "OTPField", "otp_field_input" => "OTPFieldInput", "otp_field_separator" => "OTPFieldSeparator", "otp_field_preview" => "OTPFieldPreview",
        "form_builder_otp" => "FormBuilderOTP"
      )
      Rails.autoloaders.main.collapse(COMPONENTS_PATH.join("ui/*"))
      Rails.autoloaders.main.collapse(COMPONENTS_PATH.join("blocks/*"))

      # Lookbook-only code: previews next to each component and docs helpers in app/lookbook
      unless defined?(Lookbook)
        Rails.autoloaders.main.ignore(COMPONENTS_PATH.join("ui/**/*_preview.rb"))
        Rails.autoloaders.main.ignore(COMPONENTS_PATH.join("blocks/**/*_preview.rb"))
        Rails.autoloaders.main.ignore(root.join("app/lookbook"))
      end
    end

    # Run this configuration during initialization
    initializer "ui_components.configure_action_view" do |app|
      app.config.action_view.annotate_rendered_view_with_filenames = true
    end

    # `form.ui.text_field :name` on every Rails form builder (UI::FormBuilder)
    initializer "ui_components.form_builder" do
      ActiveSupport.on_load(:action_view) do
        ActionView::Helpers::FormBuilder.include(UiComponents::FormBuilderExtension)
        Phlex::Rails::Builder.include(UiComponents::PhlexFormBuilderExtension) if defined?(Phlex::Rails::Builder)
      end
    end

    # Translations live next to each component, with preview-only strings in *_preview.locales.yml.
    initializer "ui_components.i18n" do |app|
      files = Dir[COMPONENTS_PATH.join("**/*.locales.yml")]
      files = files.reject { |file| file.end_with?("_preview.locales.yml") } unless defined?(Lookbook)
      app.config.i18n.load_path += files
    end

    # Serve the component .js/.css files straight from the component folders,
    # plus vendored third-party modules (Embla Carousel)
    initializer "ui_components.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << COMPONENTS_PATH
        app.config.assets.paths << root.join("vendor/javascript")
      end
    end

    initializer "ui_components.importmap", before: "importmap" do |app|
      app.config.importmap.paths << root.join("config/importmap.rb")
      app.config.importmap.cache_sweepers << COMPONENTS_PATH.join("ui")
      app.config.importmap.cache_sweepers << COMPONENTS_PATH.join("blocks")
      app.config.importmap.cache_sweepers << root.join("vendor/javascript")
    end

    # Previews live next to each component; docs pages (with an "On this page" nav)
    # live in docs/lookbook, in folders that mirror Appica's component categories
    initializer "ui_components.lookbook" do |app|
      if defined?(Lookbook)
        app.config.lookbook.preview_paths << COMPONENTS_PATH.to_s
        app.config.lookbook.page_paths << root.join("docs/lookbook").to_s
      end
    end
  end
end
