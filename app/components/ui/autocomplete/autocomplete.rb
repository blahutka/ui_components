# Root of the compound component. Holds the data and the shared options and
# makes itself available to its parts (AutocompleteInput, AutocompleteList, …).
#
#   Autocomplete(items: frameworks) do
#     AutocompleteInput(placeholder: "Search a framework")
#     AutocompleteContent do
#       AutocompleteEmpty { "No frameworks found." }
#       AutocompleteList do |item|
#         AutocompleteItem(value: item) { item }
#       end
#     end
#   end
class UI::Autocomplete < UI::Base
  SIZES = %i[ sm md lg ].freeze
  VARIANTS = %i[ outline soft ].freeze

  attr_reader :id, :items, :size, :variant, :value, :name

  def initialize(items: [], size: :md, variant: :outline, clearable: false, icon: false, grid: false,
                 value: nil, default_value: nil, name: nil, disabled: false, item_to_string_value: nil, **attributes)
    @items = items
    @size = SIZES.include?(size.to_sym) ? size.to_sym : :md
    @variant = VARIANTS.include?(variant.to_sym) ? variant.to_sym : :outline
    @clearable, @icon, @grid, @disabled = clearable, icon, grid, disabled
    @value = value || default_value
    @name = name
    @item_to_string_value = item_to_string_value
    @attributes = attributes
    @id = attributes.delete(:id) || "autocomplete-#{SecureRandom.hex(4)}"
  end

  def view_template(&)
    provide(:ui_autocomplete, self) do
      div(**mix(root_attributes, @attributes.except(:class)), class: cn("relative w-full", override: @attributes[:class]), &)
    end
  end

  def clearable? = @clearable
  def icon? = @icon
  def grid? = @grid
  def disabled? = @disabled

  # How the filter and the input read an item (Appica's itemToStringValue)
  def string_value_for(item)
    case @item_to_string_value
    when Proc then @item_to_string_value.call(item)
    when Symbol, String
      item.is_a?(Hash) ? item.fetch(@item_to_string_value.to_sym) { item[@item_to_string_value.to_s] } : item.public_send(@item_to_string_value)
    else
      item.to_s
    end
  end

  def list_id = "#{id}-list"

  private
    def root_attributes
      {
        id: id,
        data: {
          slot: "autocomplete",
          controller: "ui--autocomplete",
          "ui--autocomplete-grid-value": grid?
        }
      }
    end
end
