# One choice out of a set: native radio inputs sized in em, in a RadioGroup that owns the name
# and the selection.
#
# @label Radio
# @logical_path Actions & Inputs
# @component AppicaUI::RadioGroup
# @display width wide
class AppicaUI::RadioPreview < AppicaUI::BasePreview
  # Props not in the Usage form (data, render blocks, generated ids): see ui_components:preview_params
  UNLISTED_PROPS = %i[ invalid ].freeze

  PLANS = { free: "Free", pro: "Pro", team: "Team" }.freeze

  # @label Usage
  # @param orientation [Symbol] select {{ choices_for AppicaUI::RadioGroup, :orientation }}
  # @param disabled [Boolean] toggle
  # @param name text
  # @param value text
  # @param required [Boolean] toggle
  # @param default_value text
  def default(orientation: :vertical, disabled: false, name: nil, value: nil, required: false, default_value: "pro")
    phlex do
      RadioGroup(orientation:, disabled:, required:, **given(name:, value:), default_value:, aria_labelledby: "plan-label") do
        span(id: "plan-label", class: "text-foreground mb-1 text-sm font-medium") { "Plan" }
        PLANS.each do |value, text|
          label(class: "flex items-center gap-2 text-sm select-none") { Radio(value:); plain text }
        end
      end
    end
  end

  # `orientation: :horizontal` lays the options out in a row.
  def horizontal
    phlex do
      RadioGroup(orientation: :horizontal, default_value: "m", aria_label: "Size") do
        { s: "Small", m: "Medium", l: "Large" }.each do |value, text|
          label(class: "flex items-center gap-2 text-sm select-none") { Radio(value:); plain text }
        end
      end
    end
  end

  # Sized in em: a text size on the label scales the radio with it.
  def sizing
    phlex do
      RadioGroup(default_value: "base", aria_label: "Size", class: "items-start gap-4 select-none") do
        label(class: "flex items-center gap-2 text-base") { Radio(value: "base"); plain "text-base" }
        label(class: "flex items-center gap-2.5 text-lg") { Radio(value: "lg"); plain "text-lg" }
        label(class: "flex items-center gap-3 text-xl") { Radio(value: "xl"); plain "text-xl" }
      end
    end
  end

  # One option (`Radio(disabled: true)`) or the whole group.
  def disabled
    phlex do
      div(class: "flex flex-col gap-8") do
        RadioGroup(default_value: "standard", aria_label: "Shipping") do
          label(class: "flex items-center gap-2 text-sm select-none") { Radio(value: "standard"); plain "Standard" }
          label(class: "flex items-center gap-2 text-sm select-none") { Radio(value: "express"); plain "Express" }
          label(class: "text-foreground-muted flex items-center gap-2 text-sm select-none") { Radio(value: "overnight", disabled: true); plain "Overnight (unavailable)" }
        end
        RadioGroup(default_value: "yearly", disabled: true, aria_label: "Billing period") do
          label(class: "text-foreground-muted flex items-center gap-2 text-sm select-none") { Radio(value: "monthly"); plain "Monthly" }
          label(class: "text-foreground-muted flex items-center gap-2 text-sm select-none") { Radio(value: "yearly"); plain "Yearly" }
        end
      end
    end
  end

  # @label With descriptions
  def descriptions
    phlex do
      RadioGroup(default_value: "private", aria_label: "Visibility", class: "max-w-md") do
        {
          public: [ "Public", "Anyone on the internet can see this project." ],
          private: [ "Private", "Only you and people you invite can access it." ],
          team: [ "Team", "Everyone in your organization can view and edit." ]
        }.each do |value, (title, description)|
          label(class: "flex items-start gap-2.5 select-none") do
            Radio(value:, class: "mt-1")
            span(class: "flex flex-col") do
              span(class: "text-foreground-intense font-medium") { title }
              span(class: "text-foreground-muted text-sm") { description }
            end
          end
        end
      end
    end
  end

  # @label In a form
  # `required: true` on the group; inside a Field the error shows on submit.
  def form
    phlex do
      form(class: "flex flex-col items-start gap-4", data: { demo: "form" }) do
        Field(name: "plan", messages: { value_missing: "Choose a plan to continue." }) do
          FieldLabel { "Plan" }
          RadioGroup(required: true) do
            PLANS.each { |value, text| label(class: "flex items-center gap-2 text-sm select-none") { Radio(value:); plain text } }
          end
          FieldError()
        end
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
      RadioGroup(dir: "rtl", default_value: "pro", aria_label: "الخطة") do
        { free: "مجاني", pro: "احترافي", team: "فريق" }.each do |value, text|
          label(class: "flex items-center gap-2 text-sm select-none") { Radio(value:); plain text }
        end
      end
    end
  end
end
