# Maps over the items of the enclosing AutocompleteGroup
class AppicaUI::AutocompleteCollection < AppicaUI::Base
  def view_template
    consume(:ui_autocomplete_group, component: "AutocompleteGroup").items.each { |item| yield item }
  end
end
