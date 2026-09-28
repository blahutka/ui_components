require "test_helper"

class AppicaUI::AutocompleteTest < ComponentTestCase
  FRAMEWORKS = [ "Next.js", "Remix", "Astro" ]

  test "renders the compound structure with one option per item" do
    html = render_ui do
      Autocomplete(items: FRAMEWORKS, id: "frameworks") do
        AutocompleteInput(placeholder: "Search a framework")
        AutocompleteContent do
          AutocompleteEmpty { "No frameworks found." }
          AutocompleteList { |item| AutocompleteItem(value: item) { item } }
        end
      end
    end

    root = html.at_css("[data-slot=autocomplete]")
    assert_equal "appica-ui--autocomplete", root["data-controller"]

    input = html.at_css("input[data-slot=autocomplete-input-field]")
    assert_equal "combobox", input["role"]
    assert_equal "frameworks-list", input["aria-controls"]
    assert_equal "Search a framework", input["placeholder"]

    assert html.at_css("[data-slot=autocomplete-content]").key?("hidden")
    assert_equal "No frameworks found.", html.at_css("[data-slot=autocomplete-empty]").text

    options = html.css("#frameworks-list [role=option]")
    assert_equal FRAMEWORKS, options.map { |option| option["data-value"] }
    assert_equal FRAMEWORKS, options.map(&:text)
  end

  test "size and variant switch the Appica classes" do
    html = render_ui do
      Autocomplete(items: FRAMEWORKS, size: :lg, variant: :soft) do
        AutocompleteInput()
        AutocompleteContent { AutocompleteList { |item| AutocompleteItem(value: item) { item } } }
      end
    end

    group = html.at_css("[data-slot=autocomplete-input]")["class"]
    assert_includes group, "h-12"
    assert_includes group, "bg-background-muted"
    assert_includes html.at_css("[data-slot=autocomplete-content]")["class"], "rounded-xl"
    assert_includes html.at_css("[data-slot=autocomplete-item]")["class"], "py-2.5 px-3.5 text-base"
  end

  test "clearable and icon render their buttons" do
    html = render_ui do
      Autocomplete(items: FRAMEWORKS, default_value: "Remix", clearable: true, icon: true) do
        AutocompleteInput()
      end
    end

    assert_equal "Remix", html.at_css("input")["value"]
    assert_not html.at_css("[data-slot=autocomplete-clear]").key?("hidden")
    assert html.at_css("[data-slot=autocomplete-icon]")
  end

  test "object items are read through item_to_string_value" do
    html = render_ui do
      Autocomplete(items: [ { name: "Canada" }, { name: "Japan" } ], item_to_string_value: :name) do
        AutocompleteContent { AutocompleteList { |country| AutocompleteItem(value: country) { country[:name] } } }
      end
    end

    assert_equal [ "Canada", "Japan" ], html.css("[role=option]").map { |option| option["data-value"] }
  end

  test "grouped items render labelled groups" do
    html = render_ui do
      Autocomplete(items: [ { value: "Fruits", items: [ "Apple", "Banana" ] }, { value: "Herbs", items: [ "Mint" ] } ]) do
        AutocompleteContent do
          AutocompleteList do |group|
            AutocompleteGroup(items: group[:items]) do
              AutocompleteLabel { group[:value] }
              AutocompleteCollection { |item| AutocompleteItem(value: item) { item } }
            end
          end
        end
      end
    end

    groups = html.css("[data-slot=autocomplete-group]")
    assert_equal [ "Fruits", "Herbs" ], groups.map { |group| group.at_css("[data-slot=autocomplete-label]").text }
    assert_equal groups.first["aria-labelledby"], groups.first.at_css("[data-slot=autocomplete-label]")["id"]
    assert_equal [ "Apple", "Banana" ], groups.first.css("[role=option]").map(&:text)
  end

  test "static items and grid columns" do
    html = render_ui do
      Autocomplete(grid: true) do
        AutocompleteContent do
          AutocompleteList(cols: 2) do
            AutocompleteItem(value: "Rails") { "Rails" }
            AutocompleteItem(value: "Sinatra", disabled: true) { "Sinatra" }
          end
        end
      end
    end

    list = html.at_css("[data-slot=autocomplete-list]")
    assert_includes list["style"], "repeat(2,"
    assert_equal "2", list["data-cols"]
    assert html.css("[role=option]").last.key?("data-disabled")
  end

  test "caller classes override the defaults" do
    html = render_ui do
      Autocomplete { AutocompleteInput(class: "h-14 rounded-none") }
    end

    classes = html.at_css("[data-slot=autocomplete-input]")["class"].split
    assert_includes classes, "h-14"
    assert_not_includes classes, "h-10"
    assert_not_includes classes, "rounded-md"
  end

  test "parts outside the root raise a helpful error" do
    error = assert_raises(ArgumentError) { render_ui { AutocompleteList { } } }
    assert_match "must be rendered inside Autocomplete", error.message
  end
end
