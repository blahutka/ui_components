require "test_helper"

# Every component's *.locales.yml holds all its languages side by side; they must define the
# same keys, so a string added in English can't silently be missing in Czech or Arabic.
class LocalesTest < ActiveSupport::TestCase
  FILES = Dir[UiComponents::Engine::COMPONENTS_PATH.join("**/*.locales.yml")].sort

  PLURAL_FORMS = %w[ zero one two few many other ].freeze

  # Leaf keys; a pluralized entry ({ one:, few:, other: … }) counts as one key, since each
  # language has its own set of plural forms
  def keys(tree, prefix = nil)
    tree.flat_map do |key, value|
      path = [ prefix, key ].compact.join(".")
      value.is_a?(Hash) && !plural?(value) ? keys(value, path) : [ path ]
    end
  end

  def plural?(value)
    value.keys.map(&:to_s).all? { |form| PLURAL_FORMS.include?(form) } && value.key?("other")
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

  test "pluralized entries define every plural form their language needs" do
    FILES.each do |file|
      YAML.load_file(file).each do |locale, tree|
        forms = I18n.t(:"i18n.plural.keys", locale:, default: %i[ one other ]).map(&:to_s)
        plural_entries(tree).each do |path, entry|
          missing = forms - entry.keys.map(&:to_s)
          assert_empty missing, "#{file.split("/").last} #{locale}: #{path} misses plural forms #{missing.join(", ")}"
        end
      end
    end
  end

  def plural_entries(tree, prefix = nil)
    tree.flat_map do |key, value|
      path = [ prefix, key ].compact.join(".")
      next [] unless value.is_a?(Hash)

      plural?(value) ? [ [ path, value ] ] : plural_entries(value, path)
    end
  end

  test "the component translations are loaded" do
    assert_includes I18n.load_path.map(&:to_s), FILES.first
  end
end
