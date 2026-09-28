# A numeric input between − and + steppers, formatting its value (currency, percent, units…).
#
#   NumberField(default_value: 1, min: 0, max: 10, name: "quantity", aria_label: "Quantity")
#   NumberField(default_value: 19.99, step: 0.5, format: { style: "currency", currency: "USD" })
#
# The visible input is a text field (role="spinbutton") showing the formatted value; a hidden
# input carries the plain number under `name:`. ↑/↓ step (Shift: `large_step`, 10× by default; Alt: `small_step`, a tenth),
# Home/End jump to the bounds, the steppers repeat while held and disable at a bound. The value
# is parsed and re-formatted when committed (blur, Enter, a step). Emits `appica-ui--number-field:change`
# with { value } (null when empty). Inside a Field it takes the field's id, name and state.
class AppicaUI::NumberField < AppicaUI::Base
  include AppicaUI::InputStyles
  include AppicaUI::NumberFormat

  WIDTHS = { sm: "w-24", md: "w-30", lg: "w-35" }.freeze
  TEXT = {
    sm: "text-xs pointer-coarse:text-base rounded-sm gap-1.5 [&_svg:not([class*='size-'])]:size-4 [&_svg:not([class*='stroke-'])]:stroke-[1.75]",
    md: "text-sm pointer-coarse:text-base rounded-md gap-2 [&_svg:not([class*='size-'])]:size-4.5 [&_svg:not([class*='stroke-'])]:stroke-[1.65]",
    lg: "text-base rounded-lg gap-2 [&_svg:not([class*='size-'])]:size-5 [&_svg:not([class*='stroke-'])]:stroke-[1.65]"
  }.freeze
  STEPPER_SIZES = { sm: "size-7 rounded-xs [&_svg]:size-3.5!", md: "size-9 rounded-sm [&_svg]:size-4!", lg: "size-11 rounded-md [&_svg]:size-4.5!" }.freeze
  STEPPER_FILL = { outline: "before:bg-background-muted", soft: "before:bg-background" }.freeze
  STEPPER_VARIANT = "text-foreground-emphasis hover:text-foreground-intense hover:before:bg-background-subtle data-pressed:text-foreground-intense data-pressed:before:bg-background-subtle " \
    "data-pressed:before:border-border outline-ring before:border before:border-transparent before:backdrop-blur-md disabled:opacity-disabled disabled:pointer-events-none"
  INPUT = "peer text-foreground h-full w-full min-w-0 bg-transparent text-center tabular-nums outline-none"

  prop :variant,       one_of(VARIANTS, :outline), default: -> { :outline }
  prop :size,          one_of(SIZES, :md), default: -> { :md }
  prop :value,         default: -> { nil }
  prop :default_value, default: -> { nil }
  prop :min,           default: -> { nil }
  prop :max,           default: -> { nil }
  prop :step,          ->(value) { value.to_f }, default: -> { 1.0 }
  prop :small_step,    ->(value) { value.to_f }, default: -> { @step / 10 }
  prop :large_step,    ->(value) { value.to_f }, default: -> { @step * 10 }
  prop :format,        default: -> { nil }
  prop :locale,        default: -> { nil }
  prop :name,          default: -> { nil }
  prop :invalid,       default: -> { nil }
  prop :read_only,     default: -> { false }
  prop :required,      default: -> { false }
  prop :invalid_number_message, default: -> { t(".invalid_number") }
  prop :allow_wheel_scrub, default: -> { false }
  prop :increment_label, default: -> { t(".increment") }
  prop :decrement_label, default: -> { t(".decrement") }
  prop :input,         default: -> { {} }

  def view_template
    div(data: {
      slot: "number-field", invalid: flag(invalid?), disabled: flag(disabled?), controller: "appica-ui--number-field",
      "appica-ui--number-field-min-value": @min, "appica-ui--number-field-max-value": @max, "appica-ui--number-field-step-value": number(@step),
      "appica-ui--number-field-small-step-value": number(@small_step), "appica-ui--number-field-large-step-value": number(@large_step),
      "appica-ui--number-field-format-value": (@format.to_h.transform_keys { |key| key.to_s.camelize(:lower) }.to_json if @format),
      "appica-ui--number-field-locale-value": (@locale || I18n.locale).to_s,
      "appica-ui--number-field-invalid-message-value": @invalid_number_message,
      action: ("wheel->appica-ui--number-field#wheel" if @allow_wheel_scrub)
    }, class: cn(BASE, VARIANTS[@variant], TEXT[@size], STATES[:within], "h-auto shrink-0 p-px", WIDTHS[@size], override: @attributes[:class])) do
      stepper(:decrement, "M5 12h14", @decrement_label, at_bound?(@min, :<=))
      div(class: "relative flex-1 self-stretch overflow-hidden") do
        input(**control_attributes({
          type: "text", inputmode: "decimal", autocomplete: "off", autocorrect: "off", spellcheck: "false",
          id: input_id, role: "spinbutton", aria_roledescription: "Number field",
          value: (current ? display(current) : raw.presence&.to_s), aria_valuenow: (number(current) if current), aria_valuemin: (number(@min) if @min),
          aria_valuemax: (number(@max) if @max), aria_valuetext: (display(current) if current && @format),
          disabled: (true if disabled?), readonly: (true if @read_only), required: (true if @required),
          min: @min, max: @max, step: number(@step),
          aria_invalid: ("true" if invalid?), aria_describedby: field&.described_by,
          data: {
            slot: "number-field-input", invalid: flag(invalid?), "appica-ui--number-field-target": "input", "appica-ui--field-target": ("control" if field),
            action: "keydown->appica-ui--number-field#key input->appica-ui--number-field#type blur->appica-ui--number-field#commit"
          }
        }, @attributes.except(:class).merge(@input)), class: cn(INPUT, override: @input[:class]))
      end
      stepper(:increment, "M12 5v14M5 12h14", @increment_label, at_bound?(@max, :>=))
      input(type: "hidden", name: control_name, value: (current ? number(current) : raw.to_s), disabled: (true if disabled?), data: { "appica-ui--number-field-target": "hidden" }) if control_name
    end
  end

  private
    def input_id
      @input_id ||= @attributes[:id] || field&.control_id || "number-field-#{SecureRandom.hex(4)}"
    end

    def current
      value = raw
      value.to_f if numeric?(value)
    end

    def raw
      @value.nil? ? @default_value : @value
    end

    def numeric?(value)
      value.is_a?(Numeric) || value.to_s.match?(/\A\s*-?\d+(\.\d+)?\s*\z/)
    end

    def at_bound?(bound, operator)
      bound && current && current.public_send(operator, bound.to_f)
    end

    def stepper(direction, path, label, disabled)
      button(type: "button", tabindex: "-1", aria_label: label, aria_controls: input_id,
        disabled: (true if disabled? || @read_only || disabled),
        data: {
          slot: "number-field-#{direction}", "appica-ui--number-field-target": direction.to_s,
          action: "pointerdown->appica-ui--number-field#hold pointerup->appica-ui--number-field#release pointerleave->appica-ui--number-field#release click->appica-ui--number-field##{direction}"
        },
        class: cn(AppicaUI::Button::BASE, STEPPER_VARIANT, STEPPER_FILL[@variant], STEPPER_SIZES[@size])) do
        svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true") { |s| s.path(d: path) }
      end
    end

    def control_name
      @name || field&.name
    end

    def display(value)
      @format ? format_number(value, @format) : number(value)
    end

    def number(value)
      value.to_f.then { |float| float == float.to_i ? float.to_i.to_s : float.round(10).to_s }
    end
end
