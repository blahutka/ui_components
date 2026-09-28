# A Combobox with an input (or chips, when `multiple`) and one item per choice, as
# AppicaUI::FormBuilder renders it.
class AppicaUI::FormBuilderCombobox < AppicaUI::Base
  prop :combobox
  prop :input
  prop :items
  prop :placeholder, default: -> { nil }

  def view_template
    render AppicaUI::Combobox.new(items: @items.map { |value, label| { value:, label: } }, item_to_string_value: :value, item_to_string_label: :label, **@combobox) do
      render (@combobox[:multiple] ? AppicaUI::ComboboxChips : AppicaUI::ComboboxInput).new(placeholder: @placeholder, **@input)
      render AppicaUI::ComboboxContent.new do
        render(AppicaUI::ComboboxEmpty.new) { t("ui_components.appica_ui.combobox.empty") }
        render(AppicaUI::ComboboxList.new) do |item|
          render(AppicaUI::ComboboxItem.new(value: item[:value], data: { label: item[:label] })) { item[:label] }
        end
      end
    end
  end
end
