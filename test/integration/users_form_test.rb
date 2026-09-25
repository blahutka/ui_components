require "test_helper"

class UsersFormTest < ActionDispatch::IntegrationTest
  test "the full ERB form renders every form.ui helper" do
    get "/users/new"

    assert_response :success
    %w[ user[email] user[website] user[tags][] user[city] user[score] user[featured] user[alignment] user[formats][] ].each do |name|
      assert_select "form [name='#{name}']", { minimum: 1 }, name
    end
  end

  test "new form renders one address and two phone rows" do
    get "/users/new"

    assert_response :success
    assert_select 'form[action="/users"][method=post]'
    assert_select 'input[name="user[address_attributes][city]"]', count: 1
    assert_select 'input[name="user[phones_attributes][0][number]"]', count: 1
    assert_select 'input[name="user[phones_attributes][1][number]"]', count: 1
  end

  test "ordinary encoded form params save a valid user and nested records" do
    assert_difference -> { User.count } => 1, -> { Address.count } => 1, -> { Phone.count } => 2 do
      post "/users", params: URI.encode_www_form([
        [ "user[name]", "Ada" ], [ "user[email]", "ada@example.com" ], [ "user[website]", "https://ada.dev" ],
        [ "user[age]", "42" ], [ "user[bio]", "Mathematician" ],
        [ "user[locations][]", "" ], [ "user[locations][]", "prg" ], [ "user[locations][]", "ber" ],
        [ "user[plan]", "" ], [ "user[plan]", "pro" ],
        [ "user[interests][]", "" ], [ "user[interests][]", "design" ], [ "user[interests][]", "sales" ],
        [ "user[language]", "cs" ],
        [ "user[skills][]", "" ], [ "user[skills][]", "Ruby" ], [ "user[skills][]", "Rails" ],
        [ "user[experience]", "7" ], [ "user[pin]", "1234" ],
        [ "user[tags][]", "" ], [ "user[tags][]", "remote" ], [ "user[city]", "Brno" ], [ "user[score]", "4" ],
        [ "user[alignment]", "" ], [ "user[alignment]", "center" ], [ "user[formats][]", "" ], [ "user[formats][]", "bold" ],
        [ "user[featured]", "0" ], [ "user[featured]", "1" ],
        [ "user[address_attributes][city]", "Prague" ], [ "user[address_attributes][country]", "cz" ],
        [ "user[phones_attributes][0][number]", "+420 123 456 789" ], [ "user[phones_attributes][0][kind]", "mobile" ],
        [ "user[phones_attributes][1][number]", "+49 123 456 789" ], [ "user[phones_attributes][1][kind]", "work" ],
        [ "user[newsletter]", "0" ], [ "user[newsletter]", "1" ],
        [ "user[terms_of_service]", "0" ], [ "user[terms_of_service]", "1" ]
      ]), headers: { "CONTENT_TYPE" => "application/x-www-form-urlencoded" }
    end

    assert_response :success
    user = User.last
    assert_equal [ "Ada", 42, "Mathematician", "pro", "cs", 7, "1234", true ], user.values_at(:name, :age, :bio, :plan, :language, :experience, :pin, :newsletter)
    assert_equal %w[prg ber], user.locations
    assert_equal %w[design sales], user.interests
    assert_equal %w[Ruby Rails], user.skills
    assert_equal [ %w[remote], "Brno", 4, true, "center", %w[bold] ], user.values_at(:tags, :city, :score, :featured, :alignment, :formats)
    assert_equal "Prague", user.address.city
    assert_equal %w[mobile work], user.phones.order(:id).map(&:kind)
    assert_select "strong", text: "true"
    assert_select "pre" do |nodes|
      received = JSON.parse(nodes.first.text)
      assert_equal "42", received.fetch("age")
      assert_equal [ "", "prg", "ber" ], received.fetch("locations")
      assert_equal "1", received.fetch("newsletter")
    end
  end

  test "unchecked boxes and switches submit their hidden unchecked values" do
    post "/users", params: { user: valid_params.merge(newsletter: "0", terms_of_service: "0") }

    assert_response :unprocessable_entity
    user = controller.view_assigns.fetch("user")
    assert_equal false, user.newsletter
    assert user.errors[:terms_of_service].present?
    assert_select "#user_terms_of_service-field [data-slot=field-error]:not([hidden])", text: "must be accepted"
    assert_select "#user_newsletter[type=checkbox][role=switch]:not([checked])"
    assert_select 'input[type=hidden][name="user[terms_of_service]"][value="0"] + input#user_terms_of_service[value="1"][required]'
  end

  test "choices re-render from the invalid record" do
    post "/users", params: { user: valid_params.merge(name: "", plan: "", interests: [ "", "sales" ], skills: [ "", "SQL" ], language: "de", experience: "12", pin: "12") }

    assert_response :unprocessable_entity
    assert_select "#user_plan-field[data-invalid] [data-slot=field-error]:not([hidden])", text: "can't be blank"
    assert_select "#user_plan input[type=radio][checked]", count: 0
    assert_select '#user_interests_sales[checked][name="user[interests][]"]'
    assert_select "#user_interests_design:not([checked])"
    assert_select '#user_language[value="German"]'
    assert_select 'input[type=hidden][name="user[skills][]"][value="SQL"]'
    assert_select 'input[type=range][name="user[experience]"][value="12"]'
    assert_select 'input[name="user[pin]"][value="12"]'
    assert_select "#user_pin-field [data-slot=field-error]:not([hidden])", text: "must be 4 digits"
  end

  test "invalid params rerender server errors and raw age in Fields with status 422" do
    post "/users", params: { user: valid_params.merge(name: "", age: "abc") }

    assert_response :unprocessable_entity
    assert_select "#user_name-field[data-invalid] [data-slot=field-error]:not([hidden])", text: "can't be blank"
    assert_select '#user_age[value="abc"]'
    assert_select 'input[type=hidden][name="user[age]"][value="abc"]'
    assert_select "#user_age-field[data-invalid] [data-slot=field-error]:not([hidden])", text: /not a number/
  end

  test "invalid nested phone errors appear only on their own row" do
    attributes = valid_params
    attributes[:phones_attributes]["1"][:number] = "bad"
    post "/users", params: { user: attributes }

    assert_response :unprocessable_entity
    user = controller.view_assigns.fetch("user")
    assert_not user.valid?
    assert user.errors[:"phones.number"].present?
    assert user.phones.first.errors.empty?
    assert user.phones.last.errors[:number].present?
    assert_select "#user_phones_attributes_0_number-field [data-slot=field-error][hidden]"
    assert_select "#user_phones_attributes_1_number-field [data-slot=field-error]:not([hidden])", text: "should look like +420 123 456 789"
    assert_select '#user_phones_attributes_0_number[value="+420 123 456 789"]'
    assert_select '#user_phones_attributes_1_number[value="bad"]'
  end

  test "fractional ages are rejected before integer casting can hide the invalid input" do
    post "/users", params: { user: valid_params.merge(age: "18.5") }

    assert_response :unprocessable_entity
    assert_select '#user_age[value="18.5"]'
    assert_select "#user_age-field [data-slot=field-error]:not([hidden])", text: /must be an integer/
  end

  test "invalid nested address contributes a parent error and rerenders the child error" do
    attributes = valid_params
    attributes[:address_attributes][:city] = ""
    post "/users", params: { user: attributes }

    assert_response :unprocessable_entity
    assert controller.view_assigns.fetch("user").errors[:"address.city"].present?
    assert_select "#user_address_attributes_city-field [data-slot=field-error]:not([hidden])", text: "can't be blank"
  end

  test "clearing all locations submits the key and normalizes to an invalid empty array" do
    post "/users", params: { user: valid_params.merge(locations: [ "" ]) }

    assert_response :unprocessable_entity
    user = controller.view_assigns.fetch("user")
    assert_equal [], user.locations
    assert user.errors[:locations].present?
    assert_select "#user_locations-field [data-slot=field-error]:not([hidden])", text: "can't be blank"
    assert_select 'input[type=hidden][name="user[locations][]"][value=""]', count: 1
  end

  test "strong parameters ignore unpermitted top level and nested attributes" do
    attributes = valid_params.merge(id: "999", created_at: "2000-01-01")
    attributes[:address_attributes][:user_id] = "999"
    attributes[:phones_attributes]["0"][:user_id] = "999"
    post "/users", params: { user: attributes }

    assert_response :success
    user = controller.view_assigns.fetch("user")
    assert user.persisted?
    assert_not_equal 999, user.id
    assert_equal [ user.id ], [ user.address.user_id, *user.phones.map(&:user_id) ].uniq
  end

  private
    def valid_params
      {
        name: "Ada", age: "42", bio: "", locations: [ "", "prg", "ber" ], plan: "pro",
        language: "en", skills: [ "" ], experience: "3", pin: "1234", newsletter: "1", terms_of_service: "1",
        email: "ada@example.com", tags: [ "", "remote" ], city: "Prague", score: "5", alignment: "left", interests: [ "", "design" ],
        address_attributes: { city: "Prague", country: "cz" },
        phones_attributes: {
          "0" => { number: "+420 123 456 789", kind: "mobile" },
          "1" => { number: "+49 123 456 789", kind: "work" }
        }
      }
    end
end
