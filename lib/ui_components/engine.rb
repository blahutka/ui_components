require_relative "form_builder_extension"

module UiComponents
  class Engine < ::Rails::Engine
    COMPONENTS_PATH = root.join("app/components")

    # What the engine wires into its host. Both default to leaving an application alone unless it
    # is built the way the components expect, because a gem that only renders components inside
    # another engine (family_care-sms_box, say) must not change how the host itself boots.
    #
    #   importmap: :auto pins the component JavaScript only in a Propshaft + importmap host; true
    #              always, false never. Under Sprockets the pins resolve to assets the host never
    #              precompiled, and every page that emits an importmap can fail.
    #   lookbook:  registers the component previews and docs pages. Off unless the host opts in, so
    #              an application with its own Lookbook does not inherit a hundred previews that
    #              need this gem's Tailwind build to look right.
    config.ui_components = ActiveSupport::OrderedOptions.new
    config.ui_components.importmap = :auto
    config.ui_components.lookbook = false

    def self.importmap?(app)
      setting = app.config.ui_components.importmap
      return false unless app.config.respond_to?(:importmap)

      setting == :auto ? defined?(Propshaft).present? : setting.present?
    end

    def self.lookbook?(app)
      defined?(Lookbook).present? && app.config.ui_components.lookbook.present?
    end

    # Sidecar layout: app/components/appica_ui/<component>/{*.rb,*_controller.js,*.css}.
    # Collapsing the component folders keeps constants flat (AppicaUI::AutocompleteInput),
    # like the React exports, instead of AppicaUI::Autocomplete::AutocompleteInput.
    initializer "ui_components.autoloader", before: :setup_main_autoloader do |app|
      Rails.autoloaders.main.inflector.inflect(
        "appica_ui" => "AppicaUI",
        "otp_field" => "OTPField", "otp_field_input" => "OTPFieldInput", "otp_field_separator" => "OTPFieldSeparator", "otp_field_preview" => "OTPFieldPreview",
        "form_builder_otp" => "FormBuilderOTP"
      )
      primitive_folders = COMPONENTS_PATH.glob("appica_ui/*").select(&:directory?).reject { |path| path.basename.to_s == "blocks" }
      Rails.autoloaders.main.collapse(*primitive_folders)
      Rails.autoloaders.main.collapse(COMPONENTS_PATH.join("appica_ui/blocks/*"))

      # Lookbook-only code: previews next to each component and docs helpers in app/lookbook
      unless Engine.lookbook?(app)
        Rails.autoloaders.main.ignore(COMPONENTS_PATH.join("appica_ui/**/*_preview.rb"))
        Rails.autoloaders.main.ignore(root.join("app/lookbook"))
      end
    end

    # `form.ux.text_field :name` on every Rails form builder (AppicaUI::FormBuilder)
    initializer "ui_components.form_builder" do
      ActiveSupport.on_load(:action_view) do
        ActionView::Helpers::FormBuilder.include(UiComponents::FormBuilderExtension)
        Phlex::Rails::Builder.include(UiComponents::PhlexFormBuilderExtension) if defined?(Phlex::Rails::Builder)
      end
    end

    # Translations live next to each component, with preview-only strings in *_preview.locales.yml.
    initializer "ui_components.i18n" do |app|
      files = Dir[COMPONENTS_PATH.join("**/*.locales.yml")]
      files = files.reject { |file| file.end_with?("_preview.locales.yml") } unless Engine.lookbook?(app)
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
      next unless Engine.importmap?(app)

      app.config.importmap.paths << root.join("config/importmap.rb")
      app.config.importmap.cache_sweepers << COMPONENTS_PATH.join("appica_ui")
      app.config.importmap.cache_sweepers << root.join("vendor/javascript")
    end

    # Previews live next to each component; docs pages (with an "On this page" nav)
    # live in docs/lookbook, in folders that mirror Appica's component categories
    initializer "ui_components.lookbook" do |app|
      if Engine.lookbook?(app)
        app.config.lookbook.preview_paths << COMPONENTS_PATH.to_s
        app.config.lookbook.page_paths << root.join("docs/lookbook").to_s
      end
    end
  end
end
