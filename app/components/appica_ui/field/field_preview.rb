# Wires a label, description and error message to one control, with validation built in.
#
# Any control inside - Input, Textarea… - takes the field's id, name, description and its
# disabled / invalid state. Server errors come in as `error:`; in the browser the native
# constraints are checked on submit, blur or change.
#
# @label Field
# @logical_path Actions & Inputs
# @component AppicaUI::Field
# @display width wide
class AppicaUI::FieldPreview < AppicaUI::BasePreview
  # Props not in the Usage form (data, render blocks, generated ids): see ui_components:preview_params
  UNLISTED_PROPS = %i[ error invalid messages id ].freeze

  # @label Usage
  # A label above the control, a description below - all associated automatically.
  # @param name text
  # @param disabled [Boolean] toggle
  # @param validation_mode [Symbol] select {{ choices_for AppicaUI::Field, :validation_mode }}
  # @param control_id text
  def default(name: nil, disabled: false, validation_mode: :submit, control_id: "-control")
    phlex do
      Field(disabled:, validation_mode:, control_id:, **given(name:), class: "w-full max-w-70") do
        FieldLabel { "Email" }
        Input(type: "email", placeholder: "you@example.com")
        FieldDescription { "We'll send your receipt here." }
      end
    end
  end

  # `validation_mode: :blur` checks the native constraints when the field loses focus; the
  # message comes from `messages:` or the browser, and FieldError slides it in.
  def validation
    phlex do
      Field(class: "w-full max-w-70", validation_mode: :blur,
        messages: { value_missing: "Email is required", type_mismatch: "Enter a valid email address" }) do
        FieldLabel { "Email" }
        Input(type: "email", required: true, placeholder: "you@example.com")
        FieldDescription { "Validates when the field loses focus." }
        FieldError()
      end
    end
  end

  # @label Server errors
  # `error:` renders the field invalid with the server's message (e.g. from model errors); it
  # clears as soon as the value becomes valid.
  def server_error
    phlex do
      form(class: "flex w-full max-w-70 flex-col gap-4") do
        Field(name: "user[email]", error: "has already been taken") do
          FieldLabel { "Email" }
          Input(type: "email", value: "sarah@appica.dev", required: true)
          FieldError()
        end
        Field(name: "user[bio]", validation_mode: :change) do
          FieldLabel { "Bio" }
          Textarea(minlength: 20, value: "Too short", rows: 2)
          FieldError(match: :too_short) { "Tell us a little more - at least 20 characters." }
        end
      end
    end
  end

  # @label Disabled & read-only
  # `disabled:` on the Field disables its control; read-only is set on the control itself.
  def disabled
    phlex do
      div(class: "flex w-full max-w-70 flex-col gap-5") do
        Field(disabled: true) do
          FieldLabel { "Email" }
          Input(type: "email", value: "you@example.com")
          FieldDescription { "The whole field is disabled." }
        end
        Field do
          FieldLabel { "API key" }
          Input(value: "sk_live_8f2c91a4", readonly: true)
          FieldDescription { "Focusable and selectable, but not editable." }
        end
      end
    end
  end

  # Fieldset groups related fields under a legend; `disabled: true` disables them all.
  def fieldset
    phlex do
      Fieldset(class: "w-full max-w-70") do
        FieldsetLegend { "Shipping address" }
        { "Street" => "123 Main St", "City" => "Springfield", "Postal code" => "12345" }.each do |label, placeholder|
          Field do
            FieldLabel { label }
            Input(placeholder:)
          end
        end
      end
    end
  end

  # @label RTL
  def rtl
    phlex do
      div(dir: "rtl", class: "w-full max-w-70") do
        Field do
          FieldLabel { "البريد الإلكتروني" }
          Input(type: "email", placeholder: "you@example.com")
          FieldDescription { "سنرسل الإيصال إلى هنا." }
        end
      end
    end
  end
end
