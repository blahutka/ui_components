# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
require "rails/test_help"

class ComponentTestCase < ActiveSupport::TestCase
  private
    # Renders a Phlex template with the AppicaUI kit available, like application code does
    def render_ui(&template)
      html = AppicaUI::BasePreview::Example.new(template:).call
      Nokogiri::HTML5.fragment(html)
    end
end
