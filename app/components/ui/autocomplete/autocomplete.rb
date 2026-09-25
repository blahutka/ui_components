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

  prop :items,                default: -> { [] }
  prop :size,                 one_of(SIZES, :md), default: -> { :md }
  prop :variant,              one_of(VARIANTS, :outline), default: -> { :outline }
  prop :clearable,            default: -> { false }
  prop :icon,                 default: -> { false }
  prop :grid,                 default: -> { false }
  prop :value,                default: -> { nil }
  prop :default_value,        default: -> { nil }
  prop :name,                 default: -> { nil }
  prop :disabled,             default: -> { false }
  prop :item_to_string_value, default: -> { nil }
  prop :id,                   default: -> { "autocomplete-#{SecureRandom.hex(4)}" }

  attr_reader :id, :items, :size, :variant, :name

  def value
    @value || @default_value
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

  # The Stimulus controller and data-slot prefix of the parts (Combobox reuses them)
  def identifier = "ui--autocomplete"
  def slot = "autocomplete"
  def root = self

  private
    def root_attributes
      {
        id: id,
        data: {
          slot:,
          controller: identifier,
          "#{identifier}-grid-value": grid?
        }
      }
    end
end
