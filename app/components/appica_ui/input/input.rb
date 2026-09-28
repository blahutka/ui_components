# A single-line text field, with optional start/end adornments and a clear button.
#
#   Input(type: "email", placeholder: "you@example.com", aria_label: "Email")
#   Input(variant: :soft, size: :sm, start_slot: :search, clearable: true)
#   Input(start_slot: :mail, end_slot: "@example.com")
#   Input(end_slot: -> { Button(variant: :ghost, size: :sm, icon: true) { Icon(:eye) } })
#
# Native attributes (type, name, value, required, aria_*) go to the <input>. With a slot or
# `clearable:` the input sits in a wrapper that carries `class:`; `input:` then passes attributes
# to the inner <input>. `invalid: true` (or aria_invalid) paints the error state. Inside a Field it
# takes the field's id, labelling, disabled and invalid state.
class AppicaUI::Input < AppicaUI::Base
  include AppicaUI::InputStyles

  INNER = "peer text-foreground placeholder:text-foreground-subtle h-full min-w-0 flex-1 bg-transparent outline-none disabled:cursor-not-allowed"

  prop :variant,     one_of(VARIANTS, :outline), default: -> { :outline }
  prop :size,        one_of(SIZES, :md), default: -> { :md }
  prop :start_slot,  default: -> { nil }
  prop :end_slot,    default: -> { nil }
  prop :clearable,   default: -> { false }
  prop :invalid,     default: -> { nil }
  prop :clear_label, default: -> { t(".clear") }
  prop :input,       default: -> { {} }

  def view_template
    if wrapped?
      div(data: { slot: "input-wrapper", controller: ("appica-ui--input" if @clearable), invalid: flag(invalid?) },
        class: cn(input_classes(variant: @variant, size: @size, state: :within), override: @attributes[:class])) do
        div(data: { slot: "input-start" }, class: "-ms-1 flex shrink-0 items-center") { render_slot(@start_slot) } if @start_slot
        input(**control(@attributes.except(:class).merge(@input)), class: cn(INNER, override: @input[:class]))
        clear_button(slot: "input-clear", label: @clear_label) if @clearable
        div(data: { slot: "input-end" }, class: "-me-1 flex shrink-0 items-center") { render_slot(@end_slot) } if @end_slot
      end
    else
      input(**control(@attributes.except(:class)), class: cn(input_classes(variant: @variant, size: @size, state: :self), override: @attributes[:class]))
    end
  end

  private
    def wrapped?
      @start_slot || @end_slot || @clearable
    end

    def control(attributes)
      control_attributes({
        placeholder: " ", id: field&.control_id, name: field&.name,
        disabled: (true if disabled?), aria_invalid: ("true" if invalid?), aria_describedby: field&.described_by,
        data: { slot: "input", invalid: flag(invalid?), disabled: flag(disabled?), "appica-ui--input-target": ("control" if @clearable), "appica-ui--field-target": ("control" if field) }
      }, attributes)
    end
end
