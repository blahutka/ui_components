# The selected item's label inside a ComboboxTrigger; `placeholder:` when empty.
class UI::ComboboxValue < UI::Base
  prop :placeholder, default: -> { nil }

  def view_template
    value = root.values.first
    span(**mix({ data: { slot: "combobox-value", "ui--combobox-target": "valueText", placeholder_text: @placeholder } }, @attributes.except(:class)),
      class: cn("min-w-0 flex-1 truncate text-start", override: @attributes[:class])) { value ? root.label_for(value) : @placeholder.to_s }
  end

  private
    def root = consume(:ui_combobox, component: "Combobox")
end
