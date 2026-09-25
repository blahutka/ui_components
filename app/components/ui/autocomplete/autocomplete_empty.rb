# Shown only when the filter matches nothing
class UI::AutocompleteEmpty < UI::Base
  BASE = "text-foreground-muted hidden text-center group-data-empty/autocomplete-content:block"
  SIZES = { sm: "px-2.5 py-2 text-xs", md: "px-3 py-2.5 text-sm", lg: "px-3.5 py-3 text-base" }.freeze

  def view_template(&)
    div(**mix({ role: "status", aria: { live: "polite", atomic: "true" }, data: { slot: "#{root.slot}-empty" } }, @attributes.except(:class)),
        class: cn(BASE, SIZES[root.size], override: @attributes[:class]), &)
  end

  private
    def root = consume(:ui_autocomplete, component: "Autocomplete")
end
