require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f

    # For compatibility with applications that use this config
    config.action_controller.include_all_helpers = false

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])
    config.action_view.annotate_rendered_view_with_filenames = true

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # This is the gem's own component browser, so it opts in to the previews and docs pages.
    config.ui_components.lookbook = true

    # The locales the Lookbook "Locale" switch offers (number formats etc. from rails-i18n)
    config.i18n.available_locales = %i[ en cs de ar ]
    config.i18n.default_locale = :en

    config.lookbook.project_name = "UI Components"
    config.lookbook.preview_layout = "component_preview"
    # Refresh open Lookbook pages when previews, pages, components or their JS/CSS change
    config.lookbook.live_updates = true
    config.lookbook.listen_paths << UiComponents::Engine.root.join("app/components").to_s
    config.lookbook.listen_paths << Rails.root.join("app/assets/builds").to_s
    config.lookbook.listen_extensions += %w[ js css ]
    config.lookbook.preview_display_options = {
      theme: [ "light", "dark" ],
      locale: [ [ "English", "en" ], [ "Čeština", "cs" ], [ "Deutsch", "de" ], [ "العربية", "ar" ] ],
      viewport: [ "desktop", "tablet", "mobile" ],
      width: [ "narrow", "wide", "full" ]
    }
  end
end
