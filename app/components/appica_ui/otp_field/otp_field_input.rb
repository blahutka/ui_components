# One slot of an OTPField: a single-character native input. Label each one (aria_label:).
class AppicaUI::OTPFieldInput < AppicaUI::Base
  include AppicaUI::InputStyles

  WIDTHS = { sm: "w-8", md: "w-10", lg: "w-12" }.freeze
  INPUT_MODES = { numeric: "numeric", alpha: "text", alphanumeric: "text", none: "text" }.freeze

  def view_template
    index = root.next_index
    character = root.characters[index]

    input(**mix({
      type: (root.mask? ? "password" : "text"), inputmode: INPUT_MODES[root.validation_type], autocomplete: (index.zero? ? "one-time-code" : "off"),
      autocorrect: "off", spellcheck: "false", enterkeyhint: (index == root.length - 1 ? "done" : "next"), maxlength: root.length,
      value: character, disabled: (true if root.disabled?), readonly: (true if root.read_only?), aria_invalid: ("true" if root.invalid?),
      data: {
        slot: "otp-field-input", index:, filled: ("" if character), invalid: ("" if root.invalid?), disabled: ("" if root.disabled?),
        "appica-ui--otp-field-target": "input", "appica-ui--field-target": ("mirror" if root.field)
      }
    }, @attributes.except(:class)), class: cn(input_classes(variant: root.variant, size: root.size, state: :self),
      "px-0 text-center focus:placeholder:text-transparent", WIDTHS[root.size], override: @attributes[:class]))
  end

  private
    def root = consume(:ui_otp_field, component: "OTPField")
end
