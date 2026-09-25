# A set of mutually exclusive options, each a Radio on a native <input type="radio">.
#
#   RadioGroup(name: "plan", default_value: "pro", aria_label: "Plan") do
#     label(class: "flex items-center gap-2") { Radio(value: "free"); plain "Free" }
#     label(class: "flex items-center gap-2") { Radio(value: "pro"); plain "Pro" }
#   end
#
# The radios share the group's `name:` (the Field's, or a generated one, when missing), so the browser handles
# selection, arrow keys and form submission. `default_value:` picks the checked one;
# `disabled:` / `required:` apply to every option. Emits `change` like any radio.
class UI::RadioGroup < UI::Base
  ORIENTATIONS = {
    vertical: "flex flex-col gap-2",
    horizontal: "flex flex-row flex-wrap gap-x-4 gap-y-2"
  }.freeze

  prop :name,          default: -> { nil }
  prop :value,         default: -> { nil }
  prop :default_value, default: -> { nil }
  prop :orientation,   one_of(ORIENTATIONS.keys, :vertical), default: -> { :vertical }
  prop :disabled,      default: -> { false }
  prop :required,      default: -> { false }
  prop :invalid,       default: -> { nil }

  # Radios need a shared name to be exclusive: the given one, the Field's, or a generated one
  def name
    @name ||= field&.name || "radio-group-#{SecureRandom.hex(4)}"
  end

  def checked?(value)
    selected = @value.nil? ? @default_value : @value
    !selected.nil? && selected.to_s == value.to_s
  end

  def disabled? = @disabled || field&.disabled?
  def required? = @required
  def invalid? = @invalid || field&.invalid?

  def view_template(&)
    provide(:ui_radio_group, self) do
      div(**mix(defaults(
        id: field&.control_id, role: "radiogroup", aria_orientation: @orientation, aria_disabled: ("true" if disabled?),
        aria_required: ("true" if @required), aria_invalid: ("true" if invalid?), aria_describedby: field&.described_by,
        aria_labelledby: (field.label_id if field && !@attributes.key?(:aria_label)),
        data: { slot: "radio-group", disabled: ("" if disabled?), invalid: ("" if invalid?) }
      ), @attributes.except(:class)), class: cn(ORIENTATIONS[@orientation], override: @attributes[:class]), &)
    end
  end

  def field
    context[:ui_field]
  end
end
