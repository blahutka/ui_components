require "test_helper"

class UI::FormBuilderTest < ActionView::TestCase
  class ConditionalRecord
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :name, :string
    attribute :age, :integer
    validates :name, presence: { if: -> { true } }, length: { maximum: 12, unless: -> { false } }
    validates :age, numericality: { greater_than_or_equal_to: 10, less_than_or_equal_to: 20, only_integer: true }, on: :create
  end

  class BoundedRecord
    include ActiveModel::Model
    attr_accessor :age
    validates :age, numericality: { greater_than_or_equal_to: 2, less_than_or_equal_to: 8, only_integer: true }
  end

  class TaggedPhone < Phone
    attribute :tags, default: -> { [] }
  end

  Choice = Struct.new(:first, :last)

  test "text fields bind Rails names ids labels values and descriptions" do
    html = form_html(User.new(name: "Ada")) do |form|
      form.ui.text_field :name, description: "Your public name"
    end

    input = html.at_css("input#user_name")
    assert_equal "user[name]", input["name"]
    assert_equal "Ada", input["value"]
    assert_equal "Name", html.at_css('label[for="user_name"]').text.strip
    description = html.at_css("[data-slot=field-description]")
    assert_equal "Your public name", description.text
    assert_includes input["aria-describedby"].split, description["id"]
  end

  test "labels use model translations and accept explicit overrides" do
    I18n.backend.store_translations(:en, activemodel: { attributes: { user: { name: "Profile name" } } })

    html = form_html(User.new) { |form| form.ui.text_field :name }
    assert_equal "Profile name", html.at_css("label").text.strip

    html = form_html(User.new) { |form| form.ui.text_field :name, label: "Display name" }
    assert_equal "Display name", html.at_css("label").text.strip
  ensure
    I18n.backend.reload!
  end

  test "label false renders the bound control without a Field" do
    html = form_html(User.new(name: "Ada")) { |form| form.ui.text_field :name, label: false }

    assert_nil html.at_css("[data-slot=field]")
    assert_nil html.at_css("label")
    assert_equal "user[name]", html.at_css("#user_name")["name"]
    assert_equal "Ada", html.at_css("#user_name")["value"]
  end

  test "text helper variants set their input types" do
    { email_field: "email", password_field: "password", telephone_field: "tel", url_field: "url" }.each do |helper, type|
      html = form_html(User.new(name: "example")) { |form| form.ui.public_send(helper, :name) }
      assert_equal type, html.at_css("#user_name")["type"]
      assert_equal "user[name]", html.at_css("#user_name")["name"]
    end
  end

  test "unconditional validators infer browser constraints" do
    html = form_html(User.new) do |form|
      safe_join([ form.ui.text_field(:name), form.ui.number_field(:age) ])
    end

    assert html.at_css("#user_name").key?("required")
    assert_equal "40", html.at_css("#user_name")["maxlength"]
    number = html.at_css("[data-slot=number-field]")
    assert_equal "18", number["data-ui--number-field-min-value"]
    assert_equal "120", number["data-ui--number-field-max-value"]
    assert_equal "1", number["data-ui--number-field-step-value"]

    html = form_html(BoundedRecord.new) { |form| form.ui.number_field(:age) }
    number = html.at_css("[data-slot=number-field]")
    assert_equal "2", number["data-ui--number-field-min-value"]
    assert_equal "8", number["data-ui--number-field-max-value"]
  end

  test "conditional and context validators do not infer constraints" do
    html = form_html(ConditionalRecord.new) do |form|
      safe_join([ form.ui.text_field(:name), form.ui.number_field(:age, step: 0.5) ])
    end

    assert_not html.at_css("#user_name").key?("required")
    assert_nil html.at_css("#user_name")["maxlength"]
    number = html.at_css("[data-slot=number-field]")
    assert_nil number["data-ui--number-field-min-value"]
    assert_nil number["data-ui--number-field-max-value"]
    assert_equal "0.5", number["data-ui--number-field-step-value"]
  end

  test "explicit values and constraints override inferred options" do
    html = form_html(User.new(name: "Ada", age: 42)) do |form|
      safe_join([
        form.ui.text_field(:name, value: "Grace", required: false, maxlength: 80),
        form.ui.number_field(:age, value: "7", min: 0, max: 10, step: 0.5)
      ])
    end

    assert_equal "Grace", html.at_css("#user_name")["value"]
    assert_not html.at_css("#user_name").key?("required")
    assert_equal "80", html.at_css("#user_name")["maxlength"]
    assert_equal "7", html.at_css("#user_age")["value"]
    number = html.at_css("[data-slot=number-field]")
    assert_equal "0", number["data-ui--number-field-min-value"]
    assert_equal "10", number["data-ui--number-field-max-value"]
    assert_equal "0.5", number["data-ui--number-field-step-value"]
  end

  test "number fields submit ordinary values and preserve invalid raw input and errors" do
    user = User.new(name: "", age: "abc")
    user.valid?
    html = form_html(user) do |form|
      safe_join([ form.ui.text_field(:name), form.ui.number_field(:age) ])
    end

    assert_equal "abc", html.at_css("#user_age")["value"]
    assert_equal "abc", html.at_css('input[type=hidden][name="user[age]"]')["value"]
    assert_equal "user_age", html.at_css('label[for="user_age"]')["for"]
    %w[name age].each do |attribute|
      field = html.at_css("#user_#{attribute}-field")
      assert field.key?("data-invalid")
      error = field.at_css("[data-slot=field-error]")
      assert_not error.key?("hidden")
      assert_equal user.errors[attribute].to_sentence, error.text
      assert_includes html.at_css("#user_#{attribute}")["aria-describedby"].split, error["id"]
    end
  end

  test "empty number fields submit an empty string" do
    html = form_html(User.new(age: nil)) { |form| form.ui.number_field(:age) }
    assert_equal "", html.at_css('input[type=hidden][name="user[age]"]')["value"]
  end

  test "single selects normalize supported choices and display the selected label" do
    [ [ [ "Prague", "prg" ] ], { "Prague" => "prg" }, [ Choice.new("Prague", "prg") ] ].each do |choices|
      html = form_html(User.new(name: "prg")) { |form| form.ui.select(:name, choices) }
      assert_equal "prg", html.at_css('input[name="user[name]"]')["value"]
      assert_equal "Prague", html.at_css("[data-slot=select-value]").text
      assert_equal "user_name", html.at_css("[data-slot=select-trigger]")["id"]
      assert html.at_css('label[for="user_name"]')
    end

    html = form_html(User.new(name: "mobile")) { |form| form.ui.select(:name, %w[mobile home]) }
    assert_equal "mobile", html.at_css("[data-slot=select-value]").text
    assert_equal %w[mobile home], html.css("[role=option]").map { |option| option["data-value"] }
    assert_equal "mobile", html.at_css("[role=option][data-selected]")["data-value"]
  end

  test "select prompt and include blank become placeholders" do
    [ { prompt: "Pick cities" }, { include_blank: "Choose a location" } ].each do |options|
      html = form_html(User.new) { |form| form.ui.select(:name, User::LOCATIONS, options) }
      assert_equal options.values.first, html.at_css("[data-slot=select-value]").text
    end
  end

  test "boolean false remains a selected value" do
    choices = [ [ "Yes", true ], [ "No", false ] ]
    html = form_html(BoundedRecord.new(age: false)) { |form| form.ui.select(:age, choices) }
    assert_equal "No", html.at_css("[data-slot=select-value]").text
    assert_equal "false", html.at_css('input[name="user[age]"]')["value"]

    html = form_html(User.new) { |form| form.ui.select(:name, choices, selected: false) }
    assert_equal "No", html.at_css("[data-slot=select-value]").text

    html = form_html(User.new) { |form| form.ui.select(:locations, choices, { selected: [ false ] }, multiple: true) }
    assert_equal [ "", "false" ], html.css('input[name="user[locations][]"]').map { |input| input["value"] }
  end

  test "multiple selects submit an empty sentinel and selected values under an array name" do
    html = form_html(User.new(locations: %w[prg ber])) do |form|
      form.ui.select(:locations, User::LOCATIONS, { prompt: "Pick cities" }, { multiple: true })
    end

    assert_equal [ "", "prg", "ber" ], html.css('input[name="user[locations][]"]').map { |input| input["value"] }
    assert html.at_css("[data-ui--select-target=input]").key?("required")
    assert_equal "2 selected", html.at_css("[data-slot=select-value]").text
  end

  test "multiple selects allow excluding the empty sentinel and overriding required" do
    html = form_html(User.new(locations: [ "prg" ])) do |form|
      form.ui.select(:locations, User::LOCATIONS, { include_hidden: false }, { multiple: true, required: false })
    end

    assert_equal [ "prg" ], html.css('input[name="user[locations][]"]').map { |input| input["value"] }
    assert_not html.at_css("[data-ui--select-target=input]").key?("required")
    assert_equal "Prague", html.at_css("[data-slot=select-value]").text
  end

  test "nested one fields use the nested object values labels validators and errors" do
    user = User.new(address_attributes: { city: "", country: "de" })
    user.valid?
    html = form_html(user) do |form|
      form.fields_for(:address) do |address|
        safe_join([ address.ui.text_field(:city), address.ui.select(:country, Address::COUNTRIES) ])
      end
    end

    input = html.at_css("#user_address_attributes_city")
    assert_equal "user[address_attributes][city]", input["name"]
    assert_equal "", input["value"]
    assert input.key?("required")
    assert_equal Address.human_attribute_name(:city), html.at_css('label[for="user_address_attributes_city"]').text.strip
    assert_equal user.address.errors[:city].to_sentence, html.at_css("#user_address_attributes_city-field [data-slot=field-error]").text
    assert_equal "de", html.at_css('input[name="user[address_attributes][country]"]')["value"]
    assert_equal "Germany", html.at_css("[data-slot=select-value]").text
  end

  test "nested collections retain indices row values errors and stable unique Field ids" do
    user = User.new(phones_attributes: {
      "0" => { number: "+420 123 456 789", kind: "mobile" },
      "1" => { number: "bad", kind: "work" }
    })
    user.valid?
    render_rows = ->(form) do
      form.fields_for(:phones) { |phone| phone.ui.text_field(:number, description: "Include country code") }
    end
    html = form_html(user, &render_rows)

    user.phones.each_with_index do |phone, index|
      id = "user_phones_attributes_#{index}_number"
      input = html.at_css("##{id}")
      assert_equal "user[phones_attributes][#{index}][number]", input["name"]
      assert_equal phone.number, input["value"]
      assert html.at_css("label[for='#{id}']")
      error = html.at_css("##{id}-field [data-slot=field-error]")
      assert_equal phone.errors[:number].to_sentence, error.text
      assert_equal index.zero?, error.key?("hidden")
      input["aria-describedby"].split.each { |reference| assert html.at_css("[id='#{reference}']"), "Missing description or error #{reference}" }
    end

    ids = html.css("[id]").map { |node| node["id"] }
    assert_equal ids.uniq, ids
    assert_equal ids, form_html(user, &render_rows).css("[id]").map { |node| node["id"] }
  end

  test "nested child index and multiple select array names come from Rails" do
    user = User.new(phones: [ TaggedPhone.new(number: "123456", kind: "mobile", tags: [ "home" ]) ])
    html = form_html(user) do |form|
      form.fields_for(:phones) { |phone| phone.ui.select(:tags, %w[home work], {}, multiple: true) }
    end
    assert_equal [ "", "home" ], html.css('input[name="user[phones_attributes][0][tags][]"]').map { |input| input["value"] }

    html = form_html(user) do |form|
      form.fields_for(:phones, child_index: "new_phone") do |phone|
        safe_join([ phone.ui.text_field(:number), phone.ui.select(:tags, %w[home work], {}, multiple: true) ])
      end
    end

    assert_equal "user[phones_attributes][new_phone][number]", html.at_css("#user_phones_attributes_new_phone_number")["name"]
    assert_equal [ "", "home" ], html.css('input[name="user[phones_attributes][new_phone][tags][]"]').map { |input| input["value"] }
    assert html.at_css('label[for="user_phones_attributes_new_phone_tags"]')
  end

  private
    def form_html(object, &block)
      Nokogiri::HTML5.fragment(form_with(model: object, scope: :user, url: "/users", &block))
    end
end
