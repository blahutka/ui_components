# A multi-line text field - Input's appearance, variants and sizes for a <textarea>.
#
#   Textarea(rows: 4, placeholder: "Write a message…", aria_label: "Message")
#   Textarea(clearable: true, end_slot: -> { span(class: "text-xs") { "0/180" } })
#
# `rows:` seeds the height (it still resizes vertically). Slots and `clearable:` wrap it like
# Input; slots align to the first line. Inside a Field it takes the field's id and state.
class UI::Textarea < UI::Base
  include UI::InputStyles

  PADDING = { sm: "py-2", md: "py-2.5", lg: "py-3" }.freeze
  MIN_HEIGHT = { sm: "min-h-16", md: "min-h-20", lg: "min-h-24" }.freeze
  PADDING_REM = { sm: "0.5rem", md: "0.625rem", lg: "0.75rem" }.freeze
  INNER = "peer text-foreground placeholder:text-foreground-subtle min-w-0 flex-1 resize-none self-stretch bg-transparent outline-none disabled:cursor-not-allowed"
  WRAPPED_DISABLED = "has-[textarea:disabled]:border-border-strong! has-[textarea:disabled]:bg-background-subtle! has-[textarea:disabled]:opacity-disabled " \
    "has-[textarea:disabled]:cursor-not-allowed has-[textarea:disabled]:border-dashed"

  prop :variant,     one_of(VARIANTS, :outline), default: -> { :outline }
  prop :size,        one_of(SIZES, :md), default: -> { :md }
  prop :rows,        default: -> { 3 }
  prop :start_slot,  default: -> { nil }
  prop :end_slot,    default: -> { nil }
  prop :clearable,   default: -> { false }
  prop :invalid,     default: -> { nil }
  prop :value,       default: -> { nil }
  prop :clear_label, default: -> { t("ui_components.ui.input.clear") }
  prop :textarea,    default: -> { {} }

  def view_template
    if wrapped?
      div(data: { slot: "textarea-wrapper", controller: ("ui--input" if @clearable), invalid: flag(invalid?) },
        style: "--textarea-h: calc(#{@rows} * 1lh + 2 * #{PADDING_REM[@size]} + 2px)",
        class: cn(input_classes(variant: @variant, size: @size, state: :within), "h-(--textarea-h) resize-y items-start overflow-hidden",
          MIN_HEIGHT[@size], PADDING[@size], WRAPPED_DISABLED, override: @attributes[:class])) do
        div(data: { slot: "textarea-start" }, class: "-ms-1 inline-flex h-lh shrink-0 items-center") { render_slot(@start_slot) } if @start_slot
        textarea(**control(@attributes.except(:class).merge(@textarea)), class: cn(INNER, override: @textarea[:class])) { @value }
        clear_button(slot: "textarea-clear", label: @clear_label, klass: "#{CLEAR} inline-flex h-lh items-center") if @clearable
        div(data: { slot: "textarea-end" }, class: "-me-1 inline-flex h-lh shrink-0 items-center") { render_slot(@end_slot) } if @end_slot
      end
    else
      textarea(**control(@attributes.except(:class)),
        class: cn(input_classes(variant: @variant, size: @size, state: :self), "h-auto resize-y", PADDING[@size], MIN_HEIGHT[@size], override: @attributes[:class])) { @value }
    end
  end

  private
    def wrapped?
      @start_slot || @end_slot || @clearable
    end

    def invalid?
      @invalid || [ true, "true" ].include?(@attributes[:aria_invalid]) || field&.invalid?
    end

    def disabled?
      @attributes[:disabled] || field&.disabled?
    end

    def control(attributes)
      control_attributes({
        rows: @rows, id: field&.control_id, name: field&.name,
        disabled: (true if disabled?), aria_invalid: ("true" if invalid?), aria_describedby: field&.described_by,
        data: { slot: "textarea", invalid: flag(invalid?), disabled: flag(disabled?), "ui--input-target": ("control" if @clearable), "ui--field-target": ("control" if field) }
      }, attributes)
    end
end
