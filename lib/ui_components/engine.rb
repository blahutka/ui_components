module UiComponents
  class Engine < ::Rails::Engine
    COMPONENTS_PATH = root.join("app/components")

    # Sidecar layout: app/components/ui/<component>/{*.rb,*_controller.js,*.css}.
    # Collapsing the component folders keeps constants flat (UI::AutocompleteInput),
    # like the React exports, instead of UI::Autocomplete::AutocompleteInput.
    initializer "ui_components.autoloader", before: :setup_main_autoloader do
      Rails.autoloaders.main.inflector.inflect("ui" => "UI")
      Rails.autoloaders.main.collapse(COMPONENTS_PATH.join("ui/*"))

      # Lookbook-only code: previews next to each component and docs helpers in app/lookbook
      unless defined?(Lookbook)
        Rails.autoloaders.main.ignore(COMPONENTS_PATH.join("ui/**/*_preview.rb"))
        Rails.autoloaders.main.ignore(root.join("app/lookbook"))
      end
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
