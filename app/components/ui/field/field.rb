# Wires a label, description and error message to one control - Input, Textarea, Select… - and
# validates it.
#
#   Field(name: "email", validation_mode: :blur, messages: { value_missing: "Email is required" }) do
#     FieldLabel { "Email" }
#     Input(type: "email", required: true)
#     FieldDescription { "We'll send your receipt here." }
#     FieldError()
#   end
#
# `control_id:` sets the control's id (a form builder passes Rails' `user_name`).
# The control gets the field's id, `name:`, `aria-describedby`, and its disabled / invalid
# state. Server-side errors: `error: "Email is taken"` renders invalid with that message.
# In the browser, the native constraints (required, type, pattern, minlength…) are checked on
# :submit (default), :blur or :change; `messages:` overrides the browser's text per failure
# (value_missing, type_mismatch, pattern_mismatch, too_short…).
class UI::Field < UI::Base
  MODES = %i[ submit blur change ].freeze

  prop :name,            default: -> { nil }
  prop :error,           default: -> { nil }
  prop :invalid,         default: -> { nil }
  prop :disabled,        default: -> { false }
  prop :validation_mode, one_of(MODES, :submit), default: -> { :submit }
  prop :messages,        default: -> { {} }
  prop :id,              default: -> { "field-#{SecureRandom.hex(4)}" }
  prop :control_id,      default: -> { "#{@id}-control" }

  attr_reader :name, :error

  attr_reader :control_id
  def label_id = "#{@id}-label"
  def description_id = "#{@id}-description"
  def error_id = "#{@id}-error"

  def invalid? = !!(@invalid || @error.present?)
  def disabled? = @disabled

  def described_by
    [ description_id, (error_id if @error.present?) ].compact.join(" ")
  end

  def view_template(&)
    provide(:ui_field, self) do
      div(**mix(defaults(id: @id, data: {
        slot: "field", invalid: ("" if invalid?), disabled: ("" if @disabled), controller: "ui--field",
        "ui--field-mode-value": @validation_mode,
        "ui--field-messages-value": (@messages.to_h { |key, text| [ key.to_s.camelize(:lower), text ] }.to_json if @messages.any?)
      }), @attributes.except(:class)), class: @attributes[:class], &)
    end
  end
end
