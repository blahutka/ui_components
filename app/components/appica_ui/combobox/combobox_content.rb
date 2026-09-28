# The Combobox's popup. A ComboboxInput inside it becomes the search field.
class AppicaUI::ComboboxContent < AppicaUI::AutocompleteContent
  def view_template(&block)
    provide(:ui_combobox_content, true) { super(&block) }
  end
end
