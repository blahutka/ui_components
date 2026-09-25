# A tick box on a native <input type="checkbox">, sized in em so it follows the text size.
#
#   label(class: "flex items-center gap-2") do
#     Checkbox(name: "terms", checked: true)
#     plain "Accept terms and conditions"
#   end
#   Checkbox(indeterminate: true, aria_label: "Select all")
#   Checkbox(name: "newsletter", value: "1", unchecked_value: "0")   # always submits
#
# It renders only the box - wrap it and its text in a <label>. Native attributes (name, value,
# required, form, aria_*) go to the <input>, `class:` to the box. Inside a CheckboxGroup it takes
# the group's name and is checked when the group's value includes its `value:`; `parent: true`
# makes it the group's "select all" box. Inside a Field it takes the field's id and state.
class UI::Checkbox < UI::Base
  include UI::FieldControl

  ROOT = "group/checkbox relative inline-grid size-[1em] min-h-4 min-w-4 shrink-0 place-items-center align-middle " \
    "motion-safe:transition-transform motion-safe:duration-150 has-[input:active:not(:disabled)]:scale-90 " \
    "has-[input:disabled:checked]:opacity-disabled has-[input:disabled:indeterminate]:opacity-disabled"
  BOX = "peer col-start-1 row-start-1 m-0 size-full cursor-default appearance-none bg-background border-border-strong outline-ring-input " \
    "rounded-[calc(tan(atan2(var(--radius-3xs),1rem))*100%)] border outline-offset-1 transition-[background-color,border-color,box-shadow] duration-200 motion-reduce:transition-none " \
    "hover:not-checked:not-indeterminate:not-disabled:not-aria-invalid:border-border-emphasis focus-visible:border-transparent! " \
    "checked:bg-primary checked:outline-ring-primary checked:border-transparent " \
    "indeterminate:bg-primary indeterminate:outline-ring-primary indeterminate:border-transparent " \
    "disabled:not-checked:not-indeterminate:bg-background-subtle disabled:cursor-not-allowed disabled:not-checked:not-indeterminate:border-dashed " \
    "aria-invalid:border-error aria-invalid:not-checked:not-indeterminate:bg-error-subtle aria-invalid:outline-ring-error"
  INDICATOR = "text-primary-foreground pointer-events-none col-start-1 row-start-1 size-[1em] min-h-4 min-w-4"

  prop :checked,         default: -> { nil }
  prop :indeterminate,   default: -> { false }
  prop :parent,          default: -> { false }
  prop :invalid,         default: -> { nil }
  prop :value,           default: -> { nil }
  prop :unchecked_value, default: -> { nil }

  def view_template
    span(data: { slot: "checkbox" }, class: cn(ROOT, override: @attributes[:class])) do
      input(type: "hidden", name: control_name, value: @unchecked_value, form: @attributes[:form], disabled: disabled?) if @unchecked_value && control_name
      input(**control_attributes(control_defaults, @attributes.except(:class)), class: BOX)
      svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 16 16", fill: "none", stroke: "currentColor", stroke_width: "1.5",
        stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true", class: INDICATOR, data: { slot: "checkbox-indicator" }) do |s|
        s.path(d: "M4 8.5l2.5 2.5 5.5-5.5")
        s.line(x1: "4", y1: "8", x2: "12", y2: "8")
      end
    end
  end

  private
    def group
      context[:ui_checkbox_group]
    end

    def control_defaults
      {
        type: "checkbox", id: field&.control_id, name: control_name, value: @value, checked: checked?,
        disabled: (true if disabled?), aria_invalid: ("true" if invalid?), aria_describedby: field&.described_by,
        data: {
          slot: "checkbox-input", indeterminate: flag(@indeterminate), invalid: flag(invalid?),
          controller: ("ui--checkbox" if @indeterminate && !group),
          "ui--checkbox-group-target": (@parent ? "parent" : "item" if group),
          action: ("ui--checkbox-group#toggleAll" if @parent && group),
          "ui--field-target": ("control" if field)
        }
      }
    end

    def control_name
      return if @parent

      @attributes[:name] || group&.name || field&.name
    end

    def checked?
      if @checked.nil? && group && !@parent
        group.include?(@value)
      else
        @checked
      end
    end

    def disabled?
      super || group&.disabled?
    end
end
