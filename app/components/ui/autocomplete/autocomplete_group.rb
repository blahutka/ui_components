# A labelled group of options for grouped items ({ value:, items: }).
#
#   AutocompleteList do |group|
#     AutocompleteGroup(items: group[:items]) do
#       AutocompleteLabel { group[:value] }
#       AutocompleteCollection { |item| AutocompleteItem(value: item) { item } }
#     end
#   end
class UI::AutocompleteGroup < UI::Base
  prop :items

  attr_reader :items

  def label_id
    @label_id ||= "autocomplete-group-#{SecureRandom.hex(4)}"
  end

  def view_template(&)
    provide(:ui_autocomplete_group, self) do
      div(**mix({ role: "group", aria: { labelledby: label_id }, data: { slot: "#{root.slot}-group", "#{root.identifier}-target": "group" } }, @attributes.except(:class)),
          class: cn("flex flex-col gap-0.5", override: @attributes[:class]), &)
    end
  end

  private
    def root = consume(:ui_autocomplete, component: "Autocomplete")
end
