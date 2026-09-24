# A labelled group of options for grouped items ({ value:, items: }).
#
#   AutocompleteList do |group|
#     AutocompleteGroup(items: group[:items]) do
#       AutocompleteLabel { group[:value] }
#       AutocompleteCollection { |item| AutocompleteItem(value: item) { item } }
#     end
#   end
class UI::AutocompleteGroup < UI::Base
  attr_reader :items, :label_id

  def initialize(items:, **attributes)
    @items = items
    @attributes = attributes
    @label_id = "autocomplete-group-#{SecureRandom.hex(4)}"
  end

  def view_template(&)
    provide(:ui_autocomplete_group, self) do
      div(**mix({ role: "group", aria: { labelledby: label_id }, data: { slot: "autocomplete-group", "ui--autocomplete-target": "group" } }, @attributes.except(:class)),
          class: cn("flex flex-col gap-0.5", override: @attributes[:class]), &)
    end
  end
end
