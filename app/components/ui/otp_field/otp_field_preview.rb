# A one-time code split into single-character slots.
#
# @label OTP Field
# @logical_path Actions & Inputs
# @component UI::OTPField
# @display width wide
class UI::OTPFieldPreview < UI::BasePreview
  SLOTS = proc { |length, prefix = "Digit"| length.times { |index| OTPFieldInput(aria_label: "#{prefix} #{index + 1} of #{length}") } }

  # @label Usage
  # @param length number
  # @param variant [Symbol] select { choices: [outline, soft] }
  # @param size [Symbol] select { choices: [sm, md, lg] }
  # @param validation_type [Symbol] select { choices: [numeric, alpha, alphanumeric, none] }
  def default(length: 6, variant: :outline, size: :md, validation_type: :numeric)
    phlex { OTPField(length: length.to_i, variant:, size:, validation_type:, name: "code", aria_label: "Verification code") { instance_exec(length.to_i, &SLOTS) } }
  end

  def variants
    phlex do
      div(class: "flex flex-col gap-5") do
        %i[ outline soft ].each { |variant| OTPField(length: 6, variant:, aria_label: "#{variant} code") { instance_exec(6, &SLOTS) } }
      end
    end
  end

  def sizes
    phlex do
      div(class: "flex flex-col items-center gap-5") do
        %i[ sm md lg ].each { |size| OTPField(length: 4, size:, aria_label: "#{size} code") { instance_exec(4, &SLOTS) } }
      end
    end
  end

  # @label With a separator
  def separator
    phlex do
      OTPField(length: 6, aria_label: "Verification code") do
        3.times { |index| OTPFieldInput(aria_label: "Digit #{index + 1} of 6") }
        OTPFieldSeparator()
        3.upto(5) { |index| OTPFieldInput(aria_label: "Digit #{index + 1} of 6") }
      end
    end
  end

  # A `placeholder:` on each slot shows while it's empty and unfocused.
  def placeholder
    phlex { OTPField(length: 6, aria_label: "Verification code") { 6.times { |index| OTPFieldInput(placeholder: "•", aria_label: "Digit #{index + 1} of 6") } } }
  end

  # `mask: true` hides the characters.
  def masked
    phlex { OTPField(length: 6, mask: true, default_value: "135790", aria_label: "Masked code") { instance_exec(6, &SLOTS) } }
  end

  # @label Verify on complete
  # `ui--otp-field:complete` fires once every slot is filled. Try 123456 (or paste it).
  def complete
    phlex do
      div(class: "flex flex-col items-center gap-3", data: { demo: "otp" }) do
        OTPField(length: 6, aria_label: "Verification code") { instance_exec(6, &SLOTS) }
        p(class: "text-foreground-muted text-sm", aria_live: "polite", data: { demo: "status" }) { "Enter the 6-digit code (123456)" }
      end
      script(type: "module") do
        raw safe(<<~JS)
          const demo = document.querySelector("[data-demo=otp]")
          const status = demo.querySelector("[data-demo=status]")
          demo.addEventListener("ui--otp-field:change", () => status.textContent = "Enter the 6-digit code (123456)")
          demo.addEventListener("ui--otp-field:complete", ({ detail: { value } }) => {
            status.textContent = value === "123456" ? "✓ Code verified" : "✗ Incorrect code (try 123456)"
          })
        JS
      end
    end
  end

  # @label Disabled, read-only & error states
  def states
    phlex do
      div(class: "flex flex-col gap-5") do
        OTPField(length: 6, disabled: true, aria_label: "Disabled code") { instance_exec(6, "Disabled digit", &SLOTS) }
        OTPField(length: 6, read_only: true, default_value: "123456", aria_label: "Read-only code") { instance_exec(6, "Read-only digit", &SLOTS) }
        Field(invalid: true) { OTPField(length: 6, default_value: "123456", aria_label: "Code with error") { instance_exec(6, "Error digit", &SLOTS) } }
      end
    end
  end

  # @label RTL
  # The code still reads left to right, as digits do.
  def rtl
    phlex { div(dir: "rtl") { OTPField(length: 4, dir: "ltr", aria_label: "رمز التحقق") { instance_exec(4, &SLOTS) } } }
  end
end
