# A button that opens a list of options to pick one (or several with `multiple: true`).
#
#   Select(name: "fruit", default_value: "apple") do
#     SelectTrigger(aria_label: "Fruit") { SelectValue(placeholder: "Pick a fruit") }
#     SelectContent do
#       SelectItem(value: "apple") { "Apple" }
#       SelectItem(value: "orange") { "Orange" }
#     end
#   end
#
# The root holds the value and the shared `size:` / `variant:`; the popup opens in the top layer
# (so no overflow clips it), over the trigger with the selected item aligned to it
# (`align_item_with_trigger: false` to open below instead). A visually hidden input submits
# `name:` (`name[]` per value when multiple, after an empty one unless `include_hidden: false`)
# and carries `required:`. `items:` (a value → label
# Hash) lets the trigger show labels before the list is read. Emits `ui--select:change` with
# { value }. Inside a Field it takes the field's id, name and state.
class UI::Select < UI::Base
  prop :value,         default: -> { nil }
  prop :default_value, default: -> { nil }
  prop :multiple,      default: -> { false }
  prop :size,          one_of(UI::InputStyles::SIZES, :md), default: -> { :md }
  prop :variant,       one_of(UI::InputStyles::VARIANTS, :outline), default: -> { :outline }
  prop :align_item_with_trigger, default: -> { true }
  prop :items,         ->(value) { value.is_a?(Array) ? value.to_h { |item| [ item[:value].to_s, item[:label] ] } : value.to_h.transform_keys(&:to_s) }, default: -> { {} }
  prop :name,          default: -> { nil }
  prop :disabled,      default: -> { false }
  prop :required,      default: -> { false }
  prop :read_only,     default: -> { false }
  prop :id,            default: -> { "select-#{SecureRandom.hex(4)}" }
  prop :include_hidden, default: -> { true }

  attr_reader :size, :variant, :id

  def values
    value = @value.nil? ? @default_value : @value
    Array(value).compact.map(&:to_s).then { |values| @multiple ? values : values.first(1) }
  end

  def selected?(value) = values.include?(value.to_s)
  def multiple? = @multiple
  def disabled? = @disabled || field&.disabled?
  def read_only? = @read_only
  def label_for(value) = @items[value.to_s]
  def list_id = "#{@id}-list"

  def field
    context[:ui_field]
  end

  def view_template(&)
    provide(:ui_select, self) do
      div(**mix(defaults(
        id: @id,
        data: {
          slot: "select", controller: "ui--select", disabled: ("" if disabled?),
          "ui--select-multiple-value": @multiple.to_s, "ui--select-align-value": @align_item_with_trigger.to_s,
          "ui--select-name-value": control_name, "ui--select-read-only-value": @read_only.to_s,
          action: "keydown->ui--select#key focusout->ui--select#focusOut"
        }
      ), @attributes.except(:class)), class: cn("relative", override: @attributes[:class])) do
        yield
        form_inputs
      end
    end
  end

  private
    def control_name
      @name || field&.name
    end

    # One visually hidden input carries validity (required) and, for a single value, the name
    def form_inputs
      if @multiple && control_name
        # Like Rails' select: an empty entry so deselecting everything still submits the key
        input(type: "hidden", name: multiple_name, value: "", autocomplete: "off", disabled: (true if disabled?)) if @include_hidden
        values.each { |value| input(type: "hidden", name: multiple_name, value:, disabled: (true if disabled?), data: { "ui--select-target": "hidden" }) }
      end
      input(type: "text", tabindex: "-1", aria_hidden: "true", class: "sr-only", autocomplete: "off",
        name: (control_name unless @multiple), value: values.join(","), required: (true if @required), disabled: (true if disabled?),
        data: { "ui--select-target": "input", "ui--field-target": ("control" if field), action: "focus->ui--select#focusTrigger" })
    end

    def multiple_name
      control_name.to_s.end_with?("[]") ? control_name : "#{control_name}[]"
    end
end
