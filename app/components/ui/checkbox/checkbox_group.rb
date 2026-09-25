# Several checkboxes sharing one value: an array of the checked boxes' values.
#
#   CheckboxGroup(name: "toppings[]", default_value: %w[ cheese olives ], aria_labelledby: "toppings-label") do
#     span(id: "toppings-label") { "Toppings" }
#     label { Checkbox(value: "cheese"); plain "Extra cheese" }
#     label { Checkbox(value: "olives"); plain "Olives" }
#   end
#
# Every checkbox inside submits under the group's `name:` and starts checked when `default_value:`
# includes its value. One `Checkbox(parent: true)` becomes "select all": it turns indeterminate
# while only some are checked and checks or clears them all. Emits `ui--checkbox-group:change`
# with { value } (the checked values). It's a `role="group"` - name it with aria_label(ledby).
class UI::CheckboxGroup < UI::Base
  ORIENTATIONS = {
    vertical: "flex flex-col gap-2",
    horizontal: "flex flex-row flex-wrap gap-x-4 gap-y-2"
  }.freeze

  prop :name,          default: -> { nil }
  prop :value,         default: -> { nil }
  prop :default_value, ->(value) { Array(value).map(&:to_s) }, default: -> { [] }
  prop :orientation,   one_of(ORIENTATIONS.keys, :vertical), default: -> { :vertical }
  prop :disabled,      default: -> { false }

  attr_reader :name

  def include?(value)
    (@value.nil? ? @default_value : Array(@value).map(&:to_s)).include?(value.to_s)
  end

  def disabled? = @disabled || field&.disabled?

  # Inside a Field the group takes its control id, name, label and description
  def field
    context[:ui_field]
  end

  def view_template(&)
    @name ||= field&.name
    provide(:ui_checkbox_group, self) do
      div(**mix(defaults(role: "group", id: field&.control_id, aria_orientation: @orientation, aria_disabled: ("true" if disabled?),
        aria_labelledby: (field.label_id if field && !@attributes.key?(:aria_label)), aria_describedby: field&.described_by.presence,
        data: { slot: "checkbox-group", disabled: ("" if disabled?), invalid: ("" if field&.invalid?), controller: "ui--checkbox-group", action: "change->ui--checkbox-group#update" }),
        @attributes.except(:class)), class: cn(ORIENTATIONS[@orientation], override: @attributes[:class]), &)
    end
  end
end
