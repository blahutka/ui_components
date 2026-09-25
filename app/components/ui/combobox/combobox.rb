# Pick a value (or several) from a list you can filter by typing - Autocomplete's sibling for
# selection: the value is one of the items, the input reverts to its label when you leave, and it
# submits under `name:` from hidden inputs.
#
#   Combobox(items: frameworks, name: "framework", default_value: "Astro", clearable: true) do
#     ComboboxInput(placeholder: "Search a framework")
#     ComboboxContent do
#       ComboboxEmpty { "No frameworks found." }
#       ComboboxList { |item| ComboboxItem(value: item) { item } }
#     end
#   end
#
# `multiple: true` with ComboboxChips shows each value as a removable chip. ComboboxTrigger +
# ComboboxValue make a select-style field with the ComboboxInput inside ComboboxContent.
# `creatable: true` offers "Create "…"" for a query with no exact match. The chevron (`icon:`)
# is on by default. Emits `ui--combobox:change` with { value } (an array when multiple) and
# `ui--combobox:create` with { value } for a created entry.
class UI::Combobox < UI::Autocomplete
  prop :icon,      default: -> { true }
  prop :multiple,  default: -> { false }
  prop :creatable, default: -> { false }
  prop :required,  default: -> { false }
  prop :id,        default: -> { "combobox-#{SecureRandom.hex(4)}" }
  prop :item_to_string_label, default: -> { nil }

  def identifier = "ui--combobox"
  def slot = "combobox"

  def values
    value = @value.nil? ? @default_value : @value
    Array(value).compact.map { |item| item.is_a?(String) ? item : string_value_for(item) }.then { |values| @multiple ? values : values.first(1) }
  end

  # The label shown for a value: the matching item read through `item_to_string_label:`
  def label_for(value)
    item = items.find { |candidate| string_value_for(candidate) == value.to_s }
    return value.to_s unless item

    case @item_to_string_label
    when Proc then @item_to_string_label.call(item)
    when Symbol, String then item.is_a?(Hash) ? item[@item_to_string_label.to_sym] || item[@item_to_string_label.to_s] : item.public_send(@item_to_string_label)
    else string_value_for(item)
    end.to_s
  end

  def selected?(value) = values.include?(value.to_s)
  def multiple? = @multiple
  def creatable? = @creatable
  def disabled? = @disabled || field&.disabled?

  def field
    context[:ui_field]
  end

  def view_template(&)
    provide(:ui_autocomplete, self) do
      provide(:ui_combobox, self) do
        div(**mix(defaults(
          id:,
          data: {
            slot:, controller: identifier, disabled: ("" if disabled?),
            "#{identifier}-grid-value": grid?, "#{identifier}-multiple-value": @multiple.to_s,
            "#{identifier}-name-value": control_name, "#{identifier}-values-value": values.to_json,
            "#{identifier}-create-label-value": (t(".create") if @creatable)
          }
        ), @attributes.except(:class)), class: cn("relative w-full", override: @attributes[:class])) do
          yield
          form_inputs
        end
      end
    end
  end

  private
    def control_name
      @name || field&.name
    end

    def form_inputs
      if @multiple && control_name
        values.each { |value| input(type: "hidden", name: "#{control_name}[]", value:, data: { "#{identifier}-target": "hidden" }) }
      end
      input(type: "text", tabindex: "-1", aria_hidden: "true", class: "sr-only", autocomplete: "off",
        name: (control_name unless @multiple), value: values.join(","), required: (true if @required), disabled: (true if disabled?),
        data: { "#{identifier}-target": "validity", "ui--field-target": ("control" if field), action: "focus->#{identifier}#focusField" })
    end
end
