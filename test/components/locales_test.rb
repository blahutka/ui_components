require "test_helper"

# Every component's *.locales.yml holds all its languages side by side; they must define the
# same keys, so a string added in English can't silently be missing in Czech or Arabic.
class LocalesTest < ActiveSupport::TestCase
  FILES = Dir[UiComponents::Engine::COMPONENTS_PATH.join("**/*.locales.yml")].sort

  def keys(tree, prefix = nil)
    tree.flat_map { |key, value| value.is_a?(Hash) ? keys(value, [ prefix, key ].compact.join(".")) : [ [ prefix, key ].compact.join(".") ] }
  end

  test "there are component translation files" do
    assert_operator FILES.size, :>=, 2
  end

  FILES.each do |file|
    test "#{file.delete_prefix("#{UiComponents::Engine::COMPONENTS_PATH}/")} defines the same keys in every language" do
      locales = YAML.load_file(file)
      reference = keys(locales.fetch("en")).sort

      locales.each do |locale, tree|
        assert_equal reference, keys(tree).sort, "#{locale} keys differ from en"
      end
    end
  end

  test "the component translations are loaded" do
    assert_includes I18n.load_path.map(&:to_s), FILES.first
  end
end
