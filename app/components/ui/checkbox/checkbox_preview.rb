# A tick box on a native checkbox input, sized in em so it follows the surrounding text.
#
# It renders only the box - wrap it and its text in one <label>. CheckboxGroup shares one array
# value across several boxes and drives a "select all" parent.
#
# @label Checkbox
# @logical_path Actions & Inputs
# @component UI::Checkbox
# @display width wide
class UI::CheckboxPreview < UI::BasePreview
  # @label Usage
  # @param checked [Boolean] toggle
  # @param indeterminate [Boolean] toggle
  # @param disabled [Boolean] toggle
  # @param invalid [Boolean] toggle
  def default(checked: true, indeterminate: false, disabled: false, invalid: false)
    phlex do
      label(class: "flex items-center gap-2 text-sm select-none") do
        Checkbox(checked:, indeterminate:, disabled:, invalid:)
        plain "Accept terms and conditions"
      end
    end
  end

  # Unchecked, checked, indeterminate (a dash, announced as "mixed"), disabled and error.
  def states
    phlex do
      div(class: "flex flex-wrap items-center gap-6 text-sm select-none") do
        label(class: "flex items-center gap-2") { Checkbox(); plain "Unchecked" }
        label(class: "flex items-center gap-2") { Checkbox(checked: true); plain "Checked" }
        label(class: "flex items-center gap-2") { Checkbox(indeterminate: true); plain "Indeterminate" }
        label(class: "text-foreground-muted flex items-center gap-2") { Checkbox(disabled: true); plain "Disabled" }
        label(class: "text-foreground-muted flex items-center gap-2") { Checkbox(disabled: true, checked: true); plain "Disabled checked" }
        label(class: "flex items-center gap-2") { Checkbox(aria_invalid: true); plain "Error" }
      end
    end
  end

  # The box is sized in em - set a text size on the label and both grow (never below 16px).
  def sizing
    phlex do
      div(class: "flex flex-col items-start gap-4 select-none") do
        label(class: "flex items-center gap-2 text-base") { Checkbox(checked: true); plain "text-base" }
        label(class: "flex items-center gap-2.5 text-lg") { Checkbox(checked: true); plain "text-lg" }
        label(class: "flex items-center gap-3 text-xl") { Checkbox(checked: true); plain "text-xl" }
      end
    end
  end

  # @label With a label and description
  def with_label
    phlex do
      label(class: "flex max-w-sm items-start gap-2.5 select-none") do
        Checkbox(checked: true, class: "mt-1")
        span(class: "flex flex-col") do
          span(class: "text-foreground-intense font-medium") { "Enable notifications" }
          span(class: "text-foreground-muted text-sm") { "Receive emails about new activity on your account. You can turn this off any time." }
        end
      end

      label(class: "flex max-w-sm items-start gap-2.5 select-none") do
        Checkbox(checked: false, class: "mt-1")
        span(class: "flex flex-col") do
          span(class: "text-foreground-intense font-medium") { "Second label" }
          span(class: "text-foreground-muted text-sm") { "Receive emails about new activity on your account. You can turn this off any time." }
        end
      end
    end
  end

  # @label Checkbox group
  # Every box submits under the group's `name:`; `default_value:` lists the checked values.
  def group
    phlex do
      CheckboxGroup(name: "toppings[]", default_value: %w[ cheese olives ], aria_labelledby: "toppings-label") do
        span(id: "toppings-label", class: "text-foreground mb-1 text-sm font-medium") { "Toppings" }
        label(class: "flex items-center gap-2 text-sm select-none") { Checkbox(value: :cheese); plain 'Extra cheese' }
        label(class: "flex items-center gap-2 text-sm select-none") { Checkbox(value: :mushrooms); plain 'Mushrooms' }
        label(class: "flex items-center gap-2 text-sm select-none") { Checkbox(value: :olives); plain 'Olives' }
        label(class: "flex items-center gap-2 text-sm select-none") { Checkbox(value: :onions); plain 'Onions' }
      end
    end
  end

  # @label Select all (parent checkbox)
  # `Checkbox(parent: true)` follows the others - indeterminate while only some are checked -
  # and checks or clears them all.
  def select_all
    phlex do
      CheckboxGroup(name: "permissions[]", default_value: %w[ read ], aria_labelledby: "permissions-label") do
        label(class: "flex items-center gap-2 text-sm font-medium select-none") do
          Checkbox(parent: true)
          span(id: "permissions-label") { "Permissions" }
        end
        div(class: "flex flex-col gap-2 ps-6") do
          { read: "Read", write: "Write", delete: "Delete" }.each do |value, text|
            label(class: "flex items-center gap-2 text-sm select-none") { Checkbox(value:); plain text }
          end
        end
      end
    end
  end

  # @label In a form
  # Inside a Field the box is validated like any control: submit without ticking it.
  # `unchecked_value:` makes an unticked box still submit a value (like Rails' check_box).
  def form
    phlex do
      form(class: "flex flex-col items-start gap-4", data: { demo: "form" }) do
        Field(name: "terms", messages: { value_missing: "You must accept the terms to continue." }) do
          label(class: "flex items-center gap-2 text-sm select-none") { Checkbox(required: true); plain "I accept the terms" }
          FieldError()
        end
        label(class: "flex items-center gap-2 text-sm select-none") { Checkbox(name: "newsletter", value: "1", unchecked_value: "0"); plain "Send me the newsletter" }
        Button(type: "submit", size: :sm) { "Continue" }
      end
      script(type: "module") do
        raw safe(%(document.querySelector("[data-demo=form]").addEventListener("submit", event => event.preventDefault())))
      end
    end
  end

  # @label RTL
  def rtl
    phlex do
      CheckboxGroup(dir: "rtl", name: "toppings[]", default_value: %w[ cheese ], aria_label: "الإضافات") do
        { cheese: "جبن إضافي", mushrooms: "فطر", olives: "زيتون" }.each do |value, text|
          label(class: "flex items-center gap-2 text-sm select-none") { Checkbox(value:); plain text }
        end
      end
    end
  end
end
