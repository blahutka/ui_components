require "json"

# The Appica icon set (~5,000 icons from @appica/icons-react, MIT), read from the JSON files in
# ./icons that `rake ui_components:icons:sync` generates. A category's file is loaded the first
# time one of its icons is used and kept in memory.
#
#   AppicaUI::IconLibrary.fetch(:star_filled)   # => { content: "<path …/>", attrs: { fill: "currentColor" }, … }
module AppicaUI::IconLibrary
  DIRECTORY = File.expand_path("icons", __dir__)
  VIEW_BOX = "0 0 24 24".freeze

  # The svg options of the outline style, stored as `"outline": true` in the data
  OUTLINE = { fill: "none", stroke: "currentColor", stroke_width: "1.5", stroke_linecap: "round", stroke_linejoin: "round" }.freeze
  FILLED = { fill: "currentColor" }.freeze

  @categories = {}
  @lock = Mutex.new

  class << self
    def fetch(name)
      key = normalize(name)
      category = index[key] || raise(KeyError, unknown_message(name, key))
      icon = category_icons(category).fetch(key)

      {
        name: key, category:, content: icon["content"], view_box: icon["view_box"] || VIEW_BOX,
        attrs: attributes_for(icon), outline: icon["outline"] == true
      }
    end

    # :star_filled, "StarFilled", "star-filled", "sort_0_9" => "star-filled" / "sort-0-9"
    def normalize(name)
      plain = name.to_s.strip.tr("_ ", "--").downcase
      return plain if index.key?(plain)

      name.to_s.strip.gsub(/([a-z\d])([A-Z])/, '\1-\2').gsub(/([a-zA-Z])(\d)/, '\1-\2').tr("_ ", "--").squeeze("-").downcase
    end

    def names
      index.keys
    end

    def categories
      index.values.uniq.sort
    end

    # Yields [name, category] in catalog order, optionally for one category
    def each(category = nil, &)
      entries = category ? index.select { |_name, value| value == category } : index
      entries.each(&)
    end

    def index
      @index ||= JSON.parse(File.read(File.join(DIRECTORY, "index.json")))
    end

    private
      def category_icons(category)
        @categories[category] || @lock.synchronize do
          @categories[category] ||= JSON.parse(File.read(File.join(DIRECTORY, "#{category}.json")))
        end
      end

      def attributes_for(icon)
        if icon["outline"]
          OUTLINE
        elsif icon["attrs"]
          icon["attrs"].transform_keys(&:to_sym)
        else
          FILLED
        end
      end

      def unknown_message(name, key)
        suggestions = DidYouMean::SpellChecker.new(dictionary: names).correct(key).first(3)
        message = "Unknown icon #{name.inspect} (see https://appica.dev/ui/icons)"
        suggestions.any? ? "#{message}. Did you mean: #{suggestions.join(", ")}?" : message
      end
  end
end
