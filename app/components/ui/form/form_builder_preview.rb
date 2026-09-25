# Rails form helpers backed by the UI components: `form_with` as usual, `form.ui` for each
# input. One form per input; each posts to the dummy app, which shows the params it received
# and the User validation errors for those fields.
#
# @label Form builder
# @logical_path Actions & Inputs
# @display width wide
class UI::FormBuilderPreview < UI::BasePreview
  # @label Text field
  # @param errors [Boolean] toggle "Show server errors"
  def text_field(errors: false)
    user = demo_user(errors, name: "", email: "ada@", website: "example.com")

    phlex do
      form_with(model: user, url: main_app.form_submissions_path, class: "flex w-full max-w-md flex-col gap-5") do |form|
        form.ui.text_field :name, description: "As it appears on your profile"
        form.ui.email_field :email, placeholder: "ada@example.com"
        form.ui.url_field :website, placeholder: "https://"
        Button(type: "submit", class: "self-start") { "Submit" }
      end
    end
  end

  # @label Number field
  # @param errors [Boolean] toggle "Show server errors"
  def number_field(errors: false)
    user = demo_user(errors, age: "abc")

    phlex do
      form_with(model: user, url: main_app.form_submissions_path, class: "flex w-full max-w-md flex-col gap-5") do |form|
        form.ui.number_field :age, description: "Between 18 and 120 - read from the model's validators"
        Button(type: "submit", class: "self-start") { "Submit" }
      end
    end
  end

  # @label Textarea
  # @param errors [Boolean] toggle "Show server errors"
  def textarea(errors: false)
    user = demo_user(errors, bio: "Too long. " * 30)

    phlex do
      form_with(model: user, url: main_app.form_submissions_path, class: "flex w-full max-w-md flex-col gap-5") do |form|
        form.ui.text_area :bio, rows: 4, description: "Up to 280 characters"
        Button(type: "submit", class: "self-start") { "Submit" }
      end
    end
  end

  # @label Select
  # Rails' signature: `select(method, choices, options, html_options)`; `multiple: true` submits `name[]`.
  # @param errors [Boolean] toggle "Show server errors"
  def select_field(errors: false)
    user = demo_user(errors, plan: "", locations: [])

    phlex do
      form_with(model: user, url: main_app.form_submissions_path, class: "flex w-full max-w-md flex-col gap-5") do |form|
        form.ui.select :plan, User::PLANS, prompt: "Pick a plan"
        form.ui.select :locations, User::LOCATIONS, { prompt: "Pick cities" }, { multiple: true }
        form.ui.collection_select :language, User::LANGUAGES, :last, :first, { prompt: "Pick a language" }
        Button(type: "submit", class: "self-start") { "Submit" }
      end
    end
  end

  # @label Combobox
  # @param errors [Boolean] toggle "Show server errors"
  def combobox(errors: false)
    user = demo_user(errors, language: "xx")

    phlex do
      form_with(model: user, url: main_app.form_submissions_path, class: "flex w-full max-w-md flex-col gap-5") do |form|
        form.ui.combobox :language, User::LANGUAGES, placeholder: "Search a language"
        form.ui.combobox :skills, User::SKILLS, multiple: true, placeholder: "Add skills", clearable: true
        Button(type: "submit", class: "self-start") { "Submit" }
      end
    end
  end

  # @label Checkbox
  # Rails' signature: `check_box(method, options, checked_value = "1", unchecked_value = "0")`.
  # @param errors [Boolean] toggle "Show server errors"
  def checkbox(errors: false)
    user = demo_user(errors, terms_of_service: "0")

    phlex do
      form_with(model: user, url: main_app.form_submissions_path, class: "flex w-full max-w-md flex-col gap-5") do |form|
        form.ui.check_box :terms_of_service, label: "I accept the terms of service"
        form.ui.check_box :plan, { label: "Upgrade to the team plan", description: "Submits \"team\" or \"free\"" }, "team", "free"
        Button(type: "submit", class: "self-start") { "Submit" }
      end
    end
  end

  # @label Checkbox group
  # @param errors [Boolean] toggle "Show server errors"
  def checkbox_group(errors: false)
    user = demo_user(errors, interests: [])

    phlex do
      form_with(model: user, url: main_app.form_submissions_path, class: "flex w-full max-w-md flex-col gap-5") do |form|
        form.ui.checkbox_group :interests, User::INTERESTS, orientation: :horizontal
        form.ui.collection_check_boxes :skills, User::SKILLS, :itself, :itself, { label: "Skills" }, { orientation: :horizontal }
        Button(type: "submit", class: "self-start") { "Submit" }
      end
    end
  end

  # @label Chip
  # Selectable chips for an array attribute - submits `user[tags][]` like a checkbox group.
  # @param errors [Boolean] toggle "Show server errors"
  def chip(errors: false)
    user = demo_user(errors, tags: [])

    phlex do
      form_with(model: user, url: main_app.form_submissions_path, class: "flex w-full max-w-md flex-col gap-5") do |form|
        form.ui.chip_group :tags, User::TAGS, description: "Pick all that apply"
        Button(type: "submit", class: "self-start") { "Submit" }
      end
    end
  end

  # @label Radio
  # @param errors [Boolean] toggle "Show server errors"
  def radio(errors: false)
    user = demo_user(errors, plan: "")

    phlex do
      form_with(model: user, url: main_app.form_submissions_path, class: "flex w-full max-w-md flex-col gap-5") do |form|
        form.ui.radio_group :plan, User::PLANS, orientation: :horizontal
        form.ui.collection_radio_buttons :language, User::LANGUAGES.first(3), :last, :first, { label: "Language" }
        Button(type: "submit", class: "self-start") { "Submit" }
      end
    end
  end

  # @label Switch
  def switch
    phlex do
      form_with(model: User.new, url: main_app.form_submissions_path, class: "flex w-full max-w-md flex-col gap-5") do |form|
        form.ui.switch :newsletter, description: "A monthly summary, no spam"
        Button(type: "submit", class: "self-start") { "Submit" }
      end
    end
  end

  # @label Slider
  # @param errors [Boolean] toggle "Show server errors"
  def slider(errors: false)
    user = demo_user(errors, experience: 40)

    phlex do
      form_with(model: user, url: main_app.form_submissions_path, class: "flex w-full max-w-md flex-col gap-5") do |form|
        form.ui.range_field :experience, label: "Years of experience"
        Button(type: "submit", class: "self-start") { "Submit" }
      end
    end
  end

  # @label OTP field
  # @param errors [Boolean] toggle "Show server errors"
  def otp_field(errors: false)
    user = demo_user(errors, pin: "12")

    phlex do
      form_with(model: user, url: main_app.form_submissions_path, class: "flex w-full max-w-md flex-col gap-5") do |form|
        form.ui.otp_field :pin, length: 4, label: "PIN", required: true, description: "4 digits"
        Button(type: "submit", class: "self-start") { "Submit" }
      end
    end
  end

  # @label Autocomplete
  # Free text with suggestions: submits whatever is typed or picked.
  # @param errors [Boolean] toggle "Show server errors"
  def autocomplete(errors: false)
    user = demo_user(errors, city: "")

    phlex do
      form_with(model: user, url: main_app.form_submissions_path, class: "flex w-full max-w-md flex-col gap-5") do |form|
        form.ui.autocomplete :city, User::CITIES, placeholder: "Search a city"
        Button(type: "submit", class: "self-start") { "Submit" }
      end
    end
  end

  # @label Rating
  # @param errors [Boolean] toggle "Show server errors"
  def rating(errors: false)
    user = demo_user(errors, score: nil)

    phlex do
      form_with(model: user, url: main_app.form_submissions_path, class: "flex w-full max-w-md flex-col gap-5") do |form|
        form.ui.rating :score, label: "How do you like it?", clearable: true
        Button(type: "submit", class: "self-start") { "Submit" }
      end
    end
  end

  # @label Toggle
  # check_box's signature and params, as a pressable button showing the label.
  def toggle
    phlex do
      form_with(model: User.new, url: main_app.form_submissions_path, class: "flex w-full max-w-md flex-col gap-5") do |form|
        form.ui.toggle :featured, label: "Feature my profile", description: "Pinned to the top of the directory"
        Button(type: "submit", class: "self-start") { "Submit" }
      end
    end
  end

  # @label Toggle group
  # One value, or `multiple: true` for `name[]`.
  # @param errors [Boolean] toggle "Show server errors"
  def toggle_group(errors: false)
    user = demo_user(errors, alignment: "")

    phlex do
      form_with(model: user, url: main_app.form_submissions_path, class: "flex w-full max-w-md flex-col gap-5") do |form|
        form.ui.toggle_group :alignment, User::ALIGNMENTS
        form.ui.toggle_group :formats, User::FORMATS, multiple: true
        Button(type: "submit", class: "self-start") { "Submit" }
      end
    end
  end

  # @label Nested fields
  # `fields_for` builders have `ui` too: Rails supplies the `_attributes` names and row indices.
  # @param errors [Boolean] toggle "Show server errors"
  def nested_fields(errors: false)
    user = demo_user(errors, address: Address.new(city: ""), phones: [ Phone.new(number: "bad", kind: "mobile"), Phone.new(kind: "work") ])

    phlex do
      form_with(model: user, url: main_app.form_submissions_path, class: "flex w-full max-w-md flex-col gap-5") do |form|
        form.fields_for :address do |address|
          address.ui.text_field :city
          address.ui.select :country, Address::COUNTRIES, prompt: "Pick a country"
        end
        form.fields_for :phones do |phone|
          div(class: "grid min-w-0 grid-cols-1 items-start gap-3 sm:grid-cols-[minmax(0,1fr)_8rem]") do
            phone.ui.telephone_field :number, placeholder: "+420 123 456 789"
            phone.ui.select :kind, Phone::KINDS, label: "Kind"
          end
        end
        Button(type: "submit", class: "self-start") { "Submit" }
      end
    end
  end

  private
    # A new User for the demo form; with `errors` it takes the invalid values and is validated,
    # so the fields render their server errors.
    def demo_user(errors, **invalid)
      User.new_with_blank_children.tap do |user|
        if errors
          user.assign_attributes(invalid)
          user.valid?
        end
      end
    end
end
