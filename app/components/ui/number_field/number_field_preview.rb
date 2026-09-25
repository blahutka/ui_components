# A numeric input between − and + steppers, formatting its value.
#
# @label Number Field
# @logical_path Actions & Inputs
# @component UI::NumberField
# @display width wide
class UI::NumberFieldPreview < UI::BasePreview
  # @label Usage
  # @param variant [Symbol] select { choices: [outline, soft] }
  # @param size [Symbol] select { choices: [sm, md, lg] }
  # @param disabled [Boolean] toggle
  def default(variant: :outline, size: :md, disabled: false)
    phlex { NumberField(default_value: 1, min: 0, max: 10, variant:, size:, disabled:, aria_label: "Quantity") }
  end

  # The steppers invert their fill to stay legible on either variant.
  def variants
    phlex do
      div(class: "flex flex-wrap items-center gap-6") do
        NumberField(variant: :outline, default_value: 3, aria_label: "Outline quantity")
        NumberField(variant: :soft, default_value: 3, aria_label: "Soft quantity")
      end
    end
  end

  def sizes
    phlex do
      div(class: "flex flex-wrap items-center gap-6") do
        %i[ sm md lg ].each { |size| NumberField(size:, default_value: 3, aria_label: "#{size} quantity") }
      end
    end
  end

  # @label Min, max & step
  # The steppers disable at a bound; ↑/↓ step, Shift ×10, Alt ×0.1.
  def bounds
    phlex do
      Field(class: "w-fit") do
        FieldLabel(class: "mb-2") { "Rating (0-20, step 1)" }
        NumberField(default_value: 5, min: 0, max: 20, name: "rating")
      end
    end
  end

  # `format:` takes Intl.NumberFormat options (and `locale:`); the submitted value stays a plain number.
  def formatting
    phlex do
      div(class: "flex flex-wrap items-end gap-6") do
        div(class: "flex flex-col gap-1.5") do
          label(for: "nf-price", class: "text-foreground-intense text-sm font-medium") { "Price" }
          NumberField(id: "nf-price", class: "w-40", default_value: 19.99, step: 0.5, format: { style: "currency", currency: "USD" }, locale: "en-US", name: "price")
        end
        div(class: "flex flex-col gap-1.5") do
          label(for: "nf-rate", class: "text-foreground-intense text-sm font-medium") { "Rate" }
          NumberField(id: "nf-rate", class: "w-32", default_value: 0.15, min: 0, max: 1, step: 0.01, format: { style: "percent" })
        end
      end
    end
  end

  # @label Reacting to changes
  def controlled
    phlex do
      div(class: "flex flex-col items-center gap-3", data: { demo: "guests" }) do
        NumberField(default_value: 2, min: 0, aria_label: "Guests")
        p(class: "text-sm", data: { demo: "text" }) { "2 guests" }
      end
      script(type: "module") do
        raw safe(<<~JS)
          const demo = document.querySelector("[data-demo=guests]")
          demo.addEventListener("ui--number-field:change", ({ detail: { value } }) => {
            const count = value ?? 0
            demo.querySelector("[data-demo=text]").textContent = `${count} ${count === 1 ? "guest" : "guests"}`
          })
        JS
      end
    end
  end

  # @label Disabled & error states
  def states
    phlex do
      div(class: "flex flex-wrap items-center gap-6") do
        NumberField(variant: :soft, default_value: 3, disabled: true, aria_label: "Disabled quantity")
        NumberField(variant: :soft, default_value: 3, invalid: true, aria_label: "Quantity with error")
      end
    end
  end

  # @label RTL
  def rtl
    phlex { div(dir: "rtl") { NumberField(default_value: 4, min: 0, aria_label: "الكمية") } }
  end
end
