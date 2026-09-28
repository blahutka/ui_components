# An Autocomplete (free text with suggestions) with its input and list, as AppicaUI::FormBuilder renders it.
class AppicaUI::FormBuilderAutocomplete < AppicaUI::Base
  prop :autocomplete
  prop :placeholder, default: -> { nil }
  prop :input, default: -> { {} }

  def view_template
    render AppicaUI::Autocomplete.new(**@autocomplete) do
      render AppicaUI::AutocompleteInput.new(placeholder: @placeholder || " ", **@input)
      render AppicaUI::AutocompleteContent.new do
        render(AppicaUI::AutocompleteEmpty.new) { t("ui_components.appica_ui.combobox.empty") }
        render(AppicaUI::AutocompleteList.new) do |item|
          render(AppicaUI::AutocompleteItem.new(value: item)) { item }
        end
      end
    end
  end
end
