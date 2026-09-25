# Heading of an AutocompleteGroup
class UI::AutocompleteLabel < UI::Base
  SIZES = { sm: "px-2.5 pt-1.5 pb-1 text-xs", md: "px-3 pt-2 pb-1.25 text-sm", lg: "px-3.5 pt-2.5 pb-1.5 text-base" }.freeze

  def view_template(&)
    div(**mix({ id: group.label_id, data: { slot: "#{root.slot}-label" } }, @attributes.except(:class)),
        class: cn("text-foreground-subtle", SIZES[root.size], override: @attributes[:class]), &)
  end

  private
    def root = consume(:ui_autocomplete, component: "Autocomplete")
    def group = consume(:ui_autocomplete_group, component: "AutocompleteGroup")
end
