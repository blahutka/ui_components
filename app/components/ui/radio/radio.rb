# One option of a RadioGroup: a native <input type="radio"> sized in em, so it follows the text.
#
#   label(class: "flex items-center gap-2") { Radio(value: "pro"); plain "Pro" }
#
# It takes the group's name, checked state and disabled / required flags; `disabled: true`
# disables just this option (the browser then skips it with the arrow keys). `class:` styles
# the circle.
class UI::Radio < UI::Base
  ROOT = "relative inline-grid size-[1em] min-h-4 min-w-4 shrink-0 place-items-center align-middle " \
    "motion-safe:transition-transform motion-safe:duration-150 has-[input:active:not(:disabled)]:scale-90 has-[input:disabled:checked]:opacity-disabled"
  CIRCLE = "peer col-start-1 row-start-1 m-0 size-full cursor-default appearance-none bg-background border-border-strong outline-ring-input rounded-full border outline-offset-1 " \
    "transition-[background-color,border-color,box-shadow] duration-200 motion-reduce:transition-none " \
    "hover:not-checked:not-disabled:not-aria-invalid:border-border-emphasis " \
    "checked:bg-primary checked:outline-ring-primary checked:border-transparent " \
    "disabled:not-checked:bg-background-subtle disabled:cursor-not-allowed disabled:not-checked:border-dashed " \
    "aria-invalid:border-error aria-invalid:not-checked:bg-error-subtle aria-invalid:outline-ring-error"
  DOT = "bg-primary-foreground pointer-events-none col-start-1 row-start-1 size-[0.5em] min-h-2 min-w-2 rounded-full scale-0 " \
    "peer-checked:scale-100 motion-safe:transition-transform motion-safe:duration-200 motion-safe:ease-[cubic-bezier(0.175,0.885,0.32,1.5)]"

  prop :value

  def view_template
    span(data: { slot: "radio" }, class: cn(ROOT, override: @attributes[:class])) do
      input(**mix({
        type: "radio", name: group&.name, value: @value, checked: group&.checked?(@value),
        disabled: (true if group&.disabled?), required: (true if group&.required?), aria_invalid: ("true" if group&.invalid?),
        data: { slot: "radio-input", invalid: ("" if group&.invalid?), "ui--field-target": ("control" if group&.field) }
      }.compact.except(*(@attributes.keys - [ :data ])), @attributes.except(:class)), class: CIRCLE)
      span(aria_hidden: "true", class: DOT, data: { slot: "radio-indicator" })
    end
  end

  private
    def group
      context[:ui_radio_group]
    end
end
