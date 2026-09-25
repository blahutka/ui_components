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
    I18n.backend.store_translations(:en, activerecord: { attributes: { user: { name: "Profile name" } } })

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

  test "text areas bind the raw value and length constraints" do
    html = form_html(User.new(bio: "Hello")) { |form| form.ui.text_area(:bio, rows: 5) }

    textarea = html.at_css("textarea#user_bio")
    assert_equal "user[bio]", textarea["name"]
    assert_equal "Hello", textarea.text
    assert_equal "280", textarea["maxlength"]
    assert_equal "5", textarea["rows"]
    assert html.at_css('label[for="user_bio"]')
  end

  test "check boxes and switches submit Rails' hidden unchecked value before the box" do
    { check_box: :terms_of_service, switch: :newsletter }.each do |helper, attribute|
      html = form_html(User.new) { |form| form.ui.public_send(helper, attribute) }

      hidden, box = html.css("input[name='user[#{attribute}]']")
      assert_equal [ "hidden", "0" ], [ hidden["type"], hidden["value"] ]
      assert_equal [ "checkbox", "1", "user_#{attribute}" ], [ box["type"], box["value"], box["id"] ]
      assert_not box.key?("checked")
      assert html.at_css("label[for='user_#{attribute}']")
    end

    html = form_html(User.new) { |form| form.ui.check_box(:terms_of_service) }
    assert html.at_css("#user_terms_of_service").key?("required"), "acceptance validators make the box required"
  end

  test "check boxes follow Rails' checked rules and custom values" do
    [ [ true, true ], [ false, false ], [ nil, false ] ].each do |value, checked|
      html = form_html(User.new(newsletter: value)) { |form| form.ui.check_box(:newsletter) }
      assert_equal checked, html.at_css("#user_newsletter").key?("checked"), "newsletter: #{value.inspect}"
    end

    html = form_html(User.new(plan: "team")) { |form| form.ui.check_box(:plan, {}, "team", "free") }
    assert html.at_css("#user_plan[value=team]").key?("checked")
    assert_equal "free", html.at_css("input[type=hidden][name='user[plan]']")["value"]

    html = form_html(User.new) { |form| form.ui.check_box(:newsletter, include_hidden: false, checked: true, label: "Send news") }
    assert_nil html.at_css("input[type=hidden]")
    assert html.at_css("#user_newsletter").key?("checked")
    assert_equal "Send news", html.at_css("label").text.strip
  end

  test "radio groups render a hidden blank, one labelled radio per choice and the checked value" do
    html = form_html(User.new(plan: "pro")) { |form| form.ui.radio_group(:plan, User::PLANS, orientation: :horizontal) }

    assert_equal "", html.at_css("input[type=hidden][name='user[plan]']")["value"]
    group = html.at_css("#user_plan[role=radiogroup]")
    assert_equal "user_plan-field-label", group["aria-labelledby"]
    assert_equal "horizontal", group["aria-orientation"]
    radios = group.css("input[type=radio]")
    assert_equal %w[user_plan_free user_plan_pro user_plan_team], radios.map { |radio| radio["id"] }
    assert radios.all? { |radio| radio["name"] == "user[plan]" && radio.key?("required") }
    assert_equal [ "pro" ], radios.select { |radio| radio.key?("checked") }.map { |radio| radio["value"] }
    assert_equal "Pro", radios[1].ancestors("label").first.text.strip
  end

  test "checkbox groups submit an array with a blank sentinel and check the current values" do
    html = form_html(User.new(interests: %w[design sales])) { |form| form.ui.checkbox_group(:interests, User::INTERESTS) }

    inputs = html.css("input[name='user[interests][]']")
    assert_equal [ "hidden", "" ], [ inputs.first["type"], inputs.first["value"] ]
    boxes = html.css("#user_interests[role=group] input[type=checkbox]")
    assert_equal %w[user_interests_design user_interests_engineering user_interests_marketing user_interests_sales], boxes.map { |box| box["id"] }
    assert_equal %w[design sales], boxes.select { |box| box.key?("checked") }.map { |box| box["value"] }

    html = form_html(User.new) { |form| form.ui.checkbox_group(:interests, User::INTERESTS, include_hidden: false) }
    assert_nil html.at_css("input[type=hidden]")
  end

  test "collection helpers read value and text methods or procs like Rails" do
    plans = User::PLANS.map { |text, value| Choice.new(value, text) }
    html = form_html(User.new(plan: "team", interests: [ "free" ])) do |form|
      safe_join([
        form.ui.collection_radio_buttons(:plan, plans, :first, :last, { label: "Plan" }, { orientation: :horizontal }),
        form.ui.collection_check_boxes(:interests, plans, :first, ->(plan) { plan.last.upcase }),
        form.ui.collection_select(:language, plans, :first, :last, { prompt: "Pick" })
      ])
    end

    assert html.at_css("#user_plan_team[type=radio]").key?("checked")
    assert_equal "horizontal", html.at_css("#user_plan")["aria-orientation"]
    assert html.at_css("#user_interests_free[type=checkbox]").key?("checked")
    assert_equal "FREE", html.at_css("#user_interests_free").ancestors("label").first.text.strip
    assert_equal %w[free pro team], html.css("#user_language-field [role=option]").map { |option| option["data-value"] }

    html = form_html(User.new(plan: "free")) { |form| form.ui.collection_radio_buttons(:plan, plans, :first, :last, checked: "pro") }
    assert html.at_css("#user_plan_pro").key?("checked")
  end

  test "comboboxes submit values and show labels" do
    html = form_html(User.new(language: "de")) { |form| form.ui.combobox(:language, User::LANGUAGES, placeholder: "Search") }

    input = html.at_css("input#user_language[role=combobox]")
    assert_equal "German", input["value"]
    assert_equal "Search", input["placeholder"]
    assert_equal "de", html.at_css("input[name='user[language]']")["value"]
    assert_not html.at_css("input[name='user[language]']").key?("required"), "inclusion validators are not inferred"

    html = form_html(User.new) { |form| form.ui.combobox(:language, User::LANGUAGES, required: true) }
    assert html.at_css("input[name='user[language]']").key?("required")
  end

  test "multiple comboboxes submit an array with a blank sentinel" do
    html = form_html(User.new(skills: %w[Ruby SQL])) { |form| form.ui.combobox(:skills, User::SKILLS, multiple: true) }

    assert_equal [ "", "Ruby", "SQL" ], html.css("input[name='user[skills][]']").map { |input| input["value"] }
    assert_equal %w[Ruby SQL], html.css("[data-slot=combobox-chip]").map { |chip| chip.text.strip }.compact_blank
    assert html.at_css("input#user_skills[role=combobox]")
    assert html.at_css('label[for="user_skills"]')
  end

  test "range fields take numericality bounds and the current value" do
    html = form_html(User.new(experience: 7)) { |form| form.ui.range_field(:experience) }

    range = html.at_css("input#user_experience[type=range]")
    assert_equal [ "user[experience]", "7", "0", "30", "1" ], %w[name value min max step].map { |attribute| range[attribute] }
    assert_equal "user_experience-field-label", range["aria-labelledby"]
    assert html.at_css('label[for="user_experience"]')
  end

  test "otp fields submit one value and label their first input" do
    html = form_html(User.new(pin: "12")) { |form| form.ui.otp_field(:pin, length: 4, required: true) }

    hidden = html.at_css("input[name='user[pin]']")
    assert_equal [ "12", "4" ], %w[value minlength].map { |attribute| hidden[attribute] }
    inputs = html.css("[data-slot=otp-field-input]")
    assert_equal 4, inputs.size
    assert_equal [ "user_pin", nil ], inputs.first(2).map { |input| input["id"] }
    assert_equal %w[1 2], inputs.first(2).map { |input| input["value"] }
  end

  test "new helpers work in nested collections and with label false" do
    user = User.new(phones: [ TaggedPhone.new(number: "123456", kind: "home", tags: [ "work" ]) ])
    html = form_html(user) do |form|
      form.fields_for(:phones) do |phone|
        safe_join([
          phone.ui.radio_group(:kind, Phone::KINDS),
          phone.ui.checkbox_group(:tags, %w[home work]),
          phone.ui.check_box(:number, { label: false }, "123456", "")
        ])
      end
    end

    assert html.at_css('#user_phones_attributes_0_kind_home[name="user[phones_attributes][0][kind]"]').key?("checked")
    assert html.at_css('#user_phones_attributes_0_tags_work[name="user[phones_attributes][0][tags][]"]').key?("checked")
    box = html.at_css('input[type=checkbox][name="user[phones_attributes][0][number]"]')
    assert_equal "user_phones_attributes_0_number", box["id"]
    assert box.key?("checked")
    assert_nil box.ancestors("[data-slot=field]").first
  end

  test "server errors mark the new controls invalid" do
    user = User.new(plan: "", interests: [], pin: "1", terms_of_service: "0")
    user.valid?
    html = form_html(user) do |form|
      safe_join([ form.ui.radio_group(:plan, User::PLANS), form.ui.otp_field(:pin, length: 4), form.ui.check_box(:terms_of_service) ])
    end

    %w[plan pin terms_of_service].each do |attribute|
      field = html.at_css("#user_#{attribute}-field")
      assert field.key?("data-invalid"), attribute
      assert_equal user.errors[attribute].to_sentence, field.at_css("[data-slot=field-error]").text
    end
    assert_equal "true", html.at_css("#user_terms_of_service")["aria-invalid"]
    assert_equal "true", html.at_css("#user_plan")["aria-invalid"]
  end

  test "an edit form shows a persisted record's stored values and its children's ids" do
    user = User.create!(name: "Ada", age: 42, locations: %w[prg], plan: "team", interests: %w[sales], language: "de", skills: %w[SQL],
      experience: 9, pin: "4321", newsletter: true, terms_of_service: "1",
      address: Address.new(city: "Prague", country: "cz"), phones: [ Phone.new(number: "+420 123 456 789", kind: "home") ])
    user = User.find(user.id)

    html = form_html(user) do |form|
      safe_join([
        form.ui.number_field(:age), form.ui.select(:locations, User::LOCATIONS, {}, multiple: true),
        form.ui.radio_group(:plan, User::PLANS), form.ui.checkbox_group(:interests, User::INTERESTS),
        form.ui.combobox(:language, User::LANGUAGES), form.ui.combobox(:skills, User::SKILLS, multiple: true),
        form.ui.range_field(:experience), form.ui.otp_field(:pin, length: 4), form.ui.switch(:newsletter),
        form.fields_for(:address) { |address| address.ui.select(:country, Address::COUNTRIES) },
        form.fields_for(:phones) { |phone| phone.ui.radio_group(:kind, Phone::KINDS) }
      ])
    end

    assert_equal "42", html.at_css('input[type=hidden][name="user[age]"]')["value"]
    assert_equal [ "", "prg" ], html.css('input[name="user[locations][]"]').map { |input| input["value"] }
    assert html.at_css("#user_plan_team").key?("checked")
    assert html.at_css("#user_interests_sales").key?("checked")
    assert_equal "German", html.at_css("#user_language")["value"]
    assert_equal [ "", "SQL" ], html.css('input[name="user[skills][]"]').map { |input| input["value"] }
    assert_equal "9", html.at_css("#user_experience")["value"]
    assert_equal "4321", html.at_css('input[name="user[pin]"]')["value"]
    assert html.at_css("#user_newsletter").key?("checked")
    assert_equal "cz", html.at_css('input[name="user[address_attributes][country]"]')["value"]
    assert_equal user.address.id.to_s, html.at_css('input[name="user[address_attributes][id]"]')["value"]
    assert html.at_css("#user_phones_attributes_0_kind_home").key?("checked")
    assert_equal user.phones.first.id.to_s, html.at_css('input[name="user[phones_attributes][0][id]"]')["value"]
  end

  private
    def form_html(object, &block)
      Nokogiri::HTML5.fragment(form_with(model: object, scope: :user, url: "/users", &block))
    end
end
