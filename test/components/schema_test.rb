require "test_helper"

# UiComponents::Schema - the generated <component>.schema.json files for LLMs / MCP servers
class SchemaTest < ActiveSupport::TestCase
  test "component kits use only the AppicaUI namespace" do
    assert_equal AppicaUI::Button, AppicaUI.const_get(:Button, false)
    assert_equal AppicaUI::Blocks::ReviewSummary, AppicaUI::Blocks.const_get(:ReviewSummary, false)
    assert_not Object.const_defined?(:UI, false)
    assert_not Object.const_defined?(:Blocks, false)
  end

  test "props come from the prop declarations: enums, defaults, inferred types and required" do
    schema = AppicaUI::Select.to_schema

    assert_equal "object", schema["type"]
    assert_equal({ "enum" => %w[ sm md lg ], "default" => "md" }, schema["properties"]["size"])
    assert_equal({ "default" => false, "type" => "boolean" }, schema["properties"]["multiple"])
    assert_equal({ "default" => {}, "type" => "object" }, schema["properties"]["items"])
    assert_nil schema["properties"]["id"]["default"], "random defaults are left out"
    assert schema["additionalProperties"], "class:, data:, aria_* pass through"

    assert_equal [ "value" ], AppicaUI::SelectItem.to_schema["required"]
  end

  test "defaults that need the instance are left out instead of guessed" do
    step = AppicaUI::NumberField.to_schema["properties"]["small_step"]
    assert_not step.key?("default"), "@step / 10 depends on another prop"
  end

  test "a folder document describes the compound component, its nesting and working examples" do
    documents = UiComponents::Schema.documents
    select = documents.fetch(UiComponents::Schema::ROOT.join("appica_ui/select/select.schema.json"))

    assert_equal [ "Select", "AppicaUI" ], select.values_at("name", "kit")
    assert_match(/opens a list of options/, select["description"])
    assert_nil select["components"]["Select"]["description"], "the root's description is at the top only"
    assert_includes select["components"]["Select"]["parts"], "AppicaUI::SelectItem"
    assert_equal [ "AppicaUI::Select" ], select["components"]["SelectItem"]["render_inside"]
    assert_equal "https://appica.dev/ui/components/react/select", select["appica"]
    assert_equal "Usage", select["examples"].first["name"]
    assert_match(/SelectTrigger/, select["examples"].first["code"])
    assert_equal %w[ FRUIT_ITEMS FRUITS ].sort, select["example_helpers"].keys.sort

    index = documents.fetch(UiComponents::Schema::INDEX)
    entry = index["components"].find { |component| component["name"] == "Select" }
    assert_equal "appica_ui/select/select.schema.json", entry["schema"]
    assert_includes entry["parts"], "SelectItem"
    assert_not_includes entry["summary"], "\n"
  end

  test "the committed schema files are up to date" do
    stale = UiComponents::Schema.documents.reject do |path, document|
      File.exist?(path) && File.read(path) == "#{JSON.pretty_generate(document)}\n"
    end.keys

    assert_empty stale.map { |path| path.relative_path_from(UiComponents::Schema::ROOT).to_s },
      "Run `bin/rails ui_components:schema` in test/dummy to regenerate these"
  end
end
