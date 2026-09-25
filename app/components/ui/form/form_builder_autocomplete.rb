# An Autocomplete (free text with suggestions) with its input and list, as UI::FormBuilder renders it.
class UI::FormBuilderAutocomplete < UI::Base
  prop :autocomplete
  prop :placeholder, default: -> { nil }
  prop :input, default: -> { {} }

  def view_template
    render UI::Autocomplete.new(**@autocomplete) do
      render UI::AutocompleteInput.new(placeholder: @placeholder || " ", **@input)
      render UI::AutocompleteContent.new do
        render(UI::AutocompleteEmpty.new) { t("ui_components.ui.combobox.empty") }
        render(UI::AutocompleteList.new) do |item|
          render(UI::AutocompleteItem.new(value: item)) { item }
        end
      end
    end
  end
end
