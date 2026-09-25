# Appica's shared field styling (their `inputVariants`) for every text-like control - Input,
# Textarea, Select, NumberField… `:self` styles a bare control; `:within` styles a wrapper whose
# focus and invalid state come from the control inside it.
#
#   input_classes(variant: :soft, size: :sm, state: :within)
module UI::InputStyles
  include UI::FieldControl

  BASE = "w-full border text-foreground outline-none transition-[background-color,border-color,box-shadow] duration-200 motion-reduce:transition-none " \
    "[&_svg]:pointer-events-none [&_svg]:shrink-0"

  HOVER = "hover:not-focus:not-focus-visible:not-has-focus:not-has-focus-visible:not-data-popup-open:not-has-data-popup-open:not-data-pressed:not-has-data-pressed:not-data-invalid:not-has-data-invalid"

  VARIANTS = {
    outline: "bg-background border-border-strong #{HOVER}:border-border-emphasis",
    soft: "bg-background-muted border-transparent #{HOVER}:border-border-strong"
  }.freeze

  SIZES = {
    sm: "h-8 px-3 text-xs pointer-coarse:text-base rounded-sm gap-1.5 [&_svg:not([class*='size-'])]:size-4 [&_svg:not([class*='stroke-'])]:stroke-[1.75]",
    md: "h-10 px-3.5 text-sm pointer-coarse:text-base rounded-md gap-2 [&_svg:not([class*='size-'])]:size-4.5 [&_svg:not([class*='stroke-'])]:stroke-[1.65]",
    lg: "h-12 px-4 text-base rounded-lg gap-2 [&_svg:not([class*='size-'])]:size-5 [&_svg:not([class*='stroke-'])]:stroke-[1.65]"
  }.freeze

  STATES = {
    self: "focus-visible:ring-3 focus-visible:ring-ring-input focus-visible:border-transparent focus-visible:bg-background " \
      "data-popup-open:ring-3 data-popup-open:ring-ring-input data-popup-open:border-transparent data-popup-open:bg-background " \
      "data-pressed:ring-3 data-pressed:ring-ring-input data-pressed:border-transparent data-pressed:bg-background " \
      "data-invalid:bg-error-subtle data-invalid:border-error " \
      "data-invalid:focus-visible:border-transparent data-invalid:focus-visible:ring-ring-error data-invalid:focus-visible:bg-background " \
      "data-invalid:data-popup-open:border-transparent data-invalid:data-popup-open:ring-ring-error data-invalid:data-popup-open:bg-background " \
      "data-invalid:data-pressed:border-transparent data-invalid:data-pressed:ring-ring-error data-invalid:data-pressed:bg-background " \
      "data-disabled:border-border-strong! data-disabled:bg-background-subtle! data-disabled:cursor-not-allowed data-disabled:border-dashed data-disabled:opacity-disabled " \
      "placeholder:text-foreground-subtle",
    within: "flex items-center " \
      "has-focus:ring-[3px] has-focus:ring-ring-input has-focus:border-transparent has-focus:bg-background " \
      "has-data-popup-open:ring-3 has-data-popup-open:ring-ring-input has-data-popup-open:border-transparent has-data-popup-open:bg-background " \
      "has-data-pressed:ring-3 has-data-pressed:ring-ring-input has-data-pressed:border-transparent has-data-pressed:bg-background " \
      "data-invalid:bg-error-subtle data-invalid:border-error data-invalid:has-focus:border-transparent data-invalid:has-focus:ring-ring-error data-invalid:has-focus:bg-background " \
      "data-invalid:has-data-popup-open:border-transparent data-invalid:has-data-popup-open:ring-ring-error data-invalid:has-data-popup-open:bg-background " \
      "data-invalid:has-data-pressed:border-transparent data-invalid:has-data-pressed:ring-ring-error data-invalid:has-data-pressed:bg-background " \
      "has-data-invalid:bg-error-subtle has-data-invalid:border-error has-data-invalid:has-focus:border-transparent has-data-invalid:has-focus:ring-ring-error has-data-invalid:has-focus:bg-background " \
      "has-data-invalid:has-data-popup-open:border-transparent has-data-invalid:has-data-popup-open:ring-ring-error has-data-invalid:has-data-popup-open:bg-background " \
      "has-data-invalid:has-data-pressed:border-transparent has-data-invalid:has-data-pressed:ring-ring-error has-data-invalid:has-data-pressed:bg-background " \
      "has-[input:disabled]:border-border-strong! has-[input:disabled]:bg-background-subtle! has-[input:disabled]:cursor-not-allowed has-[input:disabled]:border-dashed has-[input:disabled]:opacity-disabled"
  }.freeze

  # The ✕ of a clearable control: hidden until the control has a value (its placeholder is " ")
  CLEAR = "text-foreground-subtle hover:text-foreground pointer-events-none shrink-0 cursor-pointer opacity-0 transition-[opacity,color] duration-200 " \
    "peer-not-placeholder-shown:pointer-events-auto peer-not-placeholder-shown:opacity-100 motion-reduce:transition-none"
  CLEAR_ICON = "M6.28 5.22a.75.75 0 0 0-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 1 0 1.06 1.06L10 11.06l3.72 3.72a.75.75 0 1 0 1.06-1.06L11.06 10l3.72-3.72a.75.75 0 0 0-1.06-1.06L10 8.94 6.28 5.22Z"

  private
    def input_classes(variant:, size:, state:)
      [ BASE, VARIANTS.fetch(variant), SIZES.fetch(size), STATES.fetch(state) ].join(" ")
    end

    # A slot is a block (rendered in the caller's context), an icon name or text
    def render_slot(slot)
      case slot
      when Proc then slot.call
      when Symbol then render(UI::Icon.new(slot))
      else plain(slot.to_s)
      end
    end

    def clear_button(slot:, label:, klass: CLEAR)
      button(type: "button", tabindex: "-1", aria_label: label, class: klass, data: { slot:, action: "ui--input#clear" }) do
        svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "2 2 16 16", fill: "currentColor", aria_hidden: "true", class: "size-[1em]") { |s| s.path(d: CLEAR_ICON) }
      end
    end
end
