# A Combobox with an input (or chips, when `multiple`) and one item per choice, as
# UI::FormBuilder renders it.
class UI::FormBuilderCombobox < UI::Base
  prop :combobox
  prop :input
  prop :items
  prop :placeholder, default: -> { nil }

  def view_template
    render UI::Combobox.new(items: @items.map { |value, label| { value:, label: } }, item_to_string_value: :value, item_to_string_label: :label, **@combobox) do
      render (@combobox[:multiple] ? UI::ComboboxChips : UI::ComboboxInput).new(placeholder: @placeholder, **@input)
      render UI::ComboboxContent.new do
        render(UI::ComboboxEmpty.new) { t("ui_components.ui.combobox.empty") }
        render(UI::ComboboxList.new) do |item|
          render(UI::ComboboxItem.new(value: item[:value], data: { label: item[:label] })) { item[:label] }
        end
      end
    end
  end
end
