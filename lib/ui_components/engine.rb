module UiComponents
  class Engine < ::Rails::Engine
    COMPONENTS_PATH = root.join("app/components")

    # Sidecar layout: app/components/ui/<component>/{*.rb,*_controller.js,*.css}.
    # Collapsing the component folders keeps constants flat (UI::AutocompleteInput),
    # like the React exports, instead of UI::Autocomplete::AutocompleteInput.
    initializer "ui_components.autoloader", before: :setup_main_autoloader do
      Rails.autoloaders.main.inflector.inflect("ui" => "UI")
      Rails.autoloaders.main.collapse(COMPONENTS_PATH.join("ui/*"))

      unless defined?(Lookbook)
        Rails.autoloaders.main.ignore(COMPONENTS_PATH.join("ui/**/*_preview.rb"))
      end
    end

    # Serve the component .js/.css files straight from the component folders
    initializer "ui_components.assets" do |app|
      app.config.assets.paths << COMPONENTS_PATH if app.config.respond_to?(:assets)
    end

    initializer "ui_components.importmap", before: "importmap" do |app|
      app.config.importmap.paths << root.join("config/importmap.rb")
      app.config.importmap.cache_sweepers << COMPONENTS_PATH.join("ui")
    end

    initializer "ui_components.lookbook" do |app|
      if defined?(Lookbook)
        app.config.lookbook.preview_paths << COMPONENTS_PATH.to_s
      end
    end
  end
end
