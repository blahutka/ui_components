# A one-time code split into single-character slots.
#
#   OTPField(length: 6, name: "code", aria_label: "Verification code") do
#     6.times { |index| OTPFieldInput(aria_label: "Digit #{index + 1} of 6") }
#   end
#
# Typing fills the slots and moves on, Backspace clears and moves back, ←/→ move, and pasting
# (or the OS one-time-code autofill) spreads a code across the slots. A hidden input submits the
# joined value under `name:`. `validation_type:` (:numeric, :alpha, :alphanumeric, :none)
# filters what's accepted; `mask:` hides the characters; `auto_submit:` submits the form when
# complete. Emits `ui--otp-field:change` and `ui--otp-field:complete` with { value }.
class UI::OTPField < UI::Base
  PATTERNS = { numeric: "\\d", alpha: "[A-Za-z]", alphanumeric: "[A-Za-z0-9]", none: "." }.freeze

  prop :length,          ->(value) { value.to_i }
  prop :value,           default: -> { nil }
  prop :default_value,   default: -> { nil }
  prop :variant,         one_of(UI::InputStyles::VARIANTS, :outline), default: -> { :outline }
  prop :size,            one_of(UI::InputStyles::SIZES, :md), default: -> { :md }
  prop :validation_type, one_of(PATTERNS, :numeric), default: -> { :numeric }
  prop :mask,            default: -> { false }
  prop :auto_submit,     default: -> { false }
  prop :name,            default: -> { nil }
  prop :required,        default: -> { false }
  prop :disabled,        default: -> { false }
  prop :read_only,       default: -> { false }
  prop :invalid,         default: -> { nil }

  attr_reader :length, :variant, :size, :validation_type

  def characters
    (@value.nil? ? @default_value : @value).to_s.chars.first(@length)
  end

  # Each OTPFieldInput takes the next slot
  def next_index
    @index = (@index || -1) + 1
  end

  def mask? = @mask
  def disabled? = @disabled || field&.disabled?
  def read_only? = @read_only
  def invalid? = @invalid || field&.invalid?

  def field
    context[:ui_field]
  end

  def view_template(&)
    provide(:ui_otp_field, self) do
      div(**mix(defaults(
        role: "group", aria_labelledby: (field.label_id if field && !@attributes.key?(:aria_label)), aria_describedby: field&.described_by,
        data: {
          slot: "otp-field", controller: "ui--otp-field", disabled: ("" if disabled?), invalid: ("" if invalid?),
          "ui--otp-field-pattern-value": PATTERNS[@validation_type], "ui--otp-field-auto-submit-value": @auto_submit.to_s,
          action: "input->ui--otp-field#type keydown->ui--otp-field#key paste->ui--otp-field#paste focusin->ui--otp-field#select"
        }
      ), @attributes.except(:class)), class: cn("flex w-fit items-center gap-1", override: @attributes[:class])) do
        yield
        input(type: "text", tabindex: "-1", aria_hidden: "true", class: "sr-only", name: (@name || field&.name), value: characters.join,
          required: (true if @required), minlength: (@length if @required), disabled: (true if disabled?), autocomplete: "one-time-code",
          data: { "ui--otp-field-target": "hidden", "ui--field-target": ("control" if field), action: "focus->ui--otp-field#focusFirst" })
      end
    end
  end
end
