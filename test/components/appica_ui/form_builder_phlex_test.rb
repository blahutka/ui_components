require "test_helper"

# `form.ux` inside a Phlex view: phlex-rails' form_with yields its own builder, whose helpers
# write straight into the view's output.
class AppicaUI::FormBuilderPhlexTest < ActionView::TestCase
  class ProfileForm < AppicaUI::Base
    include Phlex::Rails::Helpers::FormWith

    attr_reader :builders

    def initialize(user:)
      @user = user
      @builders = []
    end

    def view_template
      form_with(model: @user, url: "/users") do |form|
        builders << form
        form.ux.text_field :name
        form.ux.chip_group :tags, User::TAGS
        form.fields_for :address do |address|
          builders << address
          address.ux.text_field :city
        end
        form.submit "Save"
      end
    end
  end

  test "form.ux helpers render once, unescaped and in order inside the form" do
    user = User.new(name: "Ada", tags: %w[remote], address: Address.new(city: "Prague"))
    component = ProfileForm.new(user:)
    html = Nokogiri::HTML5.fragment(render(component))

    form = html.at_css("form[action='/users']")
    assert form
    component.builders.each do |builder|
      assert_respond_to builder, :ux
      assert_not_respond_to builder, :ui
    end
    assert_equal 1, form.css("input#user_name").size
    assert_equal "Ada", form.at_css("input#user_name")["value"]
    assert_equal "Prague", form.at_css("input[name='user[address_attributes][city]']")["value"]
    assert form.at_css("#user_tags_remote").key?("checked")
    assert_equal %w[user_name-field user_tags-field user_address_attributes_city-field], form.css("[data-slot=field]").map { |field| field["id"] }
    assert form.at_css("input[type=submit][value=Save]")
    assert_not_includes html.to_html, "&lt;div"
  end
end
