require "test_helper"

class UsersFormTest < ActionDispatch::IntegrationTest
  test "Lookbook preview posts to the host application users route" do
    get "/lookbook/preview/Actions%20&%20Inputs/form_builder/default"

    assert_response :success
    assert_select 'form[action="/users"][method=post]'
    assert_select '#user_phones_attributes_0_kind-field [role=option][data-selected][data-value=mobile]'
  end

  test "new form renders one address and two phone rows" do
    get "/users/new"

    assert_response :success
    assert_select 'form[action="/users"][method=post]'
    assert_select 'input[name="user[address_attributes][city]"]', count: 1
    assert_select 'input[name="user[phones_attributes][0][number]"]', count: 1
    assert_select 'input[name="user[phones_attributes][1][number]"]', count: 1
  end

  test "ordinary encoded form params build a valid user and nested records" do
    post "/users", params: URI.encode_www_form([
      [ "user[name]", "Ada" ], [ "user[age]", "42" ],
      [ "user[locations][]", "" ], [ "user[locations][]", "prg" ], [ "user[locations][]", "ber" ],
      [ "user[address_attributes][city]", "Prague" ], [ "user[address_attributes][country]", "cz" ],
      [ "user[phones_attributes][0][number]", "+420 123 456 789" ], [ "user[phones_attributes][0][kind]", "mobile" ],
      [ "user[phones_attributes][1][number]", "+49 123 456 789" ], [ "user[phones_attributes][1][kind]", "work" ]
    ]), headers: { "CONTENT_TYPE" => "application/x-www-form-urlencoded" }

    assert_response :success
    user = controller.view_assigns.fetch("user")
    assert user.valid?, user.errors.full_messages.to_sentence
    assert_equal 42, user.age
    assert_equal %w[prg ber], user.locations
    assert_equal "Prague", user.address.city
    assert_equal %w[mobile work], user.phones.map(&:kind)
    assert_select "strong", text: "true"
    assert_select "pre" do |nodes|
      received = JSON.parse(nodes.first.text)
      assert_equal "42", received.fetch("age")
      assert_equal [ "", "prg", "ber" ], received.fetch("locations")
    end
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
    assert user.errors[:phones].present?
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
    assert controller.view_assigns.fetch("user").errors[:address].present?
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
    attributes = valid_params.merge(admin: "1")
    attributes[:address_attributes][:admin] = "1"
    attributes[:phones_attributes]["0"][:admin] = "1"
    post "/users", params: { user: attributes }

    assert_response :success
    assert controller.view_assigns.fetch("user").valid?
  end

  private
    def valid_params
      {
        name: "Ada", age: "42", locations: [ "", "prg", "ber" ],
        address_attributes: { city: "Prague", country: "cz" },
        phones_attributes: {
          "0" => { number: "+420 123 456 789", kind: "mobile" },
          "1" => { number: "+49 123 456 789", kind: "work" }
        }
      }
    end
end
