require "test_helper"

class FormBuilderPreviewsTest < ActionDispatch::IntegrationTest
  SCENARIOS = {
    text_field: %w[ user[name] user[email] user[website] ],
    number_field: %w[ user[age] ],
    textarea: %w[ user[bio] ],
    select_field: %w[ user[plan] user[locations][] user[language] ],
    combobox: %w[ user[language] user[skills][] ],
    checkbox: %w[ user[terms_of_service] user[plan] ],
    checkbox_group: %w[ user[interests][] user[skills][] ],
    chip: %w[ user[tags][] ],
    radio: %w[ user[plan] user[language] ],
    switch: %w[ user[newsletter] ],
    slider: %w[ user[experience] ],
    otp_field: %w[ user[pin] ],
    autocomplete: %w[ user[city] ],
    rating: %w[ user[score] ],
    toggle: %w[ user[featured] ],
    toggle_group: %w[ user[alignment] user[formats][] ],
    nested_fields: %w[ user[address_attributes][city] user[phones_attributes][1][number] ]
  }.freeze

  SCENARIOS.each do |scenario, names|
    test "#{scenario} preview renders one form posting to form submissions" do
      get "/lookbook/preview/Actions%20&%20Inputs/form_builder/#{scenario}"

      assert_response :success
      assert_select 'form[action="/form_submissions"][method=post]', count: 1
      names.each { |name| assert_select "form [name='#{name}']", minimum: 1 }
      assert_select "form button[type=submit]", text: "Submit"
    end
  end

  test "the errors param renders server errors in the fields" do
    (SCENARIOS.keys - %i[ switch toggle ]).each do |scenario|
      get "/lookbook/preview/Actions%20&%20Inputs/form_builder/#{scenario}?errors=true"

      assert_response :success
      assert_select "form [data-slot=field][data-invalid] [data-slot=field-error]:not([hidden])", { minimum: 1 }, "#{scenario} shows no server error"
    end
  end

  test "form submissions show the params and only the submitted fields' errors" do
    post "/form_submissions", params: { user: { plan: "", tags: [ "", "remote" ] } }

    assert_response :success
    assert_select "pre", text: /"tags"/
    assert_select "strong[data-valid=false]"
    assert_select "li", count: 1, text: "Plan can't be blank"

    post "/form_submissions", params: { user: { tags: [ "", "remote" ], alignment: "", formats: [ "", "bold" ] } }
    assert_select "li", count: 1, text: /Alignment/

    post "/form_submissions", params: { user: { address_attributes: { city: "Prague", country: "cz" } } }
    assert_select "strong[data-valid=true]"
  end
end
