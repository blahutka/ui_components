require "test_helper"

class AppicaUI::ComboboxTest < ComponentTestCase
  FRAMEWORKS = [ "Next.js", "Remix", "Astro" ].freeze

  test "shows the selected label, submits the value and checks the item" do
    combobox = render_ui do
      Combobox(items: FRAMEWORKS, default_value: "Astro", name: "framework", clearable: true) do
        ComboboxInput(placeholder: "Search")
        ComboboxContent { ComboboxList { |item| ComboboxItem(value: item) { item } } }
      end
    end
    root = combobox.at_css("[data-slot=combobox]")

    assert_equal "appica-ui--combobox", root["data-controller"]
    assert_equal [ "Astro" ], JSON.parse(root["data-appica-ui--combobox-values-value"])
    assert_equal "Astro", combobox.at_css("[data-slot=combobox-input-field]")["value"]
    assert_nil combobox.at_css("[data-slot=combobox-input-field]")["name"]
    assert_equal [ "framework", "Astro" ], combobox.at_css("input.sr-only").then { |input| [ input["name"], input["value"] ] }
    assert_equal [ "false", "false", "true" ], combobox.css("[role=option]").map { |option| option["aria-selected"] }
    assert combobox.at_css("[data-slot=combobox-item][data-value=Astro][data-selected]")
    assert combobox.at_css("[data-slot=combobox-toggle], [data-slot=autocomplete-icon], [data-slot=combobox-icon]"), "chevron on by default"
    assert_equal "Clear selection", combobox.at_css("[data-slot=combobox-clear]")["aria-label"]
  end

  test "object items read their value and label" do
    countries = [ { code: "cz", name: "Czechia" }, { code: "de", name: "Germany" } ]
    combobox = render_ui do
      Combobox(items: countries, item_to_string_value: :code, item_to_string_label: :name, default_value: "de") do
        ComboboxInput()
        ComboboxContent { ComboboxList { |country| ComboboxItem(value: country[:code]) { country[:name] } } }
      end
    end

    assert_equal "Germany", combobox.at_css("[data-slot=combobox-input-field]")["value"]
    assert_equal "de", combobox.at_css("input.sr-only")["value"]
  end

  test "multiple renders chips, hidden inputs and a chip template" do
    combobox = render_ui do
      Combobox(items: FRAMEWORKS, multiple: true, default_value: %w[ Remix Astro ], name: "frameworks", creatable: true) do
        ComboboxChips(placeholder: "Add")
        ComboboxContent { ComboboxList { |item| ComboboxItem(value: item) { item } } }
      end
    end

    assert_equal %w[ Remix Astro ], combobox.css("[data-slot=combobox-chips-list] > [data-slot=combobox-chip]").map { |chip| chip["data-value"] }
    assert_equal [ "", "Remix", "Astro" ], combobox.css("input[type=hidden][name='frameworks[]']").map { |input| input["value"] }
    assert combobox.at_css("template[data-appica-ui--combobox-target=chipTemplate]")
    assert_equal %(Create "%{query}"), combobox.at_css("[data-slot=combobox]")["data-appica-ui--combobox-create-label-value"]
  end

  test "a trigger with the search inside the popup" do
    combobox = render_ui do
      Combobox(items: FRAMEWORKS, icon: false, default_value: "Remix") do
        ComboboxTrigger(aria_label: "Framework") { ComboboxValue(placeholder: "Pick") }
        ComboboxContent do
          ComboboxInput(placeholder: "Search")
          ComboboxList { |item| ComboboxItem(value: item) { item } }
        end
      end
    end

    assert_equal "anchor trigger", combobox.at_css("[data-slot=combobox-trigger]")["data-appica-ui--combobox-target"]
    assert_equal "Remix", combobox.at_css("[data-slot=combobox-value]").text
    assert_nil combobox.at_css("[data-slot=combobox-content] [data-slot=combobox-input-field]")["value"]
  end
end
