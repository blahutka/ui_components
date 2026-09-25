# A score input built from a row of stars - or any icon pair - with fractional values.
#
# A radiogroup of icon buttons that fills from the start up to the value. The pointer previews
# what a click would set and lifts the icon under it; arrow keys step by `step`. The accent is
# the text color. `read_only:` shows a labelled, non-interactive average.
#
# @label Rating
# @logical_path Actions & Inputs
# @component UI::Rating
# @display width wide
class UI::RatingPreview < UI::BasePreview
  # @label Usage
  # @param default_value number
  # @param step [Symbol] select { choices: [1, 0.5, 0.25] }
  # @param variant [Symbol] select { choices: [filled, outline] }
  # @param clearable [Boolean] toggle
  # @param disabled [Boolean] toggle
  def default(default_value: 3, step: :"1", variant: :filled, clearable: false, disabled: false)
    phlex do
      Rating(default_value: default_value.to_f, step: step.to_s.to_f, variant:, clearable:, disabled:, aria_label: "Rate this product")
    end
  end

  # The star is built in; `icon:` takes any icon name with a -filled twin (or an
  # `{ empty:, filled: }` pair).
  def icons
    phlex do
      div(class: "flex flex-col gap-3") do
        [ [ "Star", :star, nil ], [ "Heart", :heart, "text-error-emphasis" ], [ "Thumb up", :thumb_up, "text-success-emphasis" ],
          [ "Bolt", :bolt, "text-warning-emphasis" ], [ "Crown", :crown_2, "text-secondary-emphasis" ] ].each do |label, icon, color|
          div(class: "flex items-center gap-4") do
            span(class: "w-20 text-sm") { label }
            Rating(default_value: 4, icon:, class: color, aria_label: "#{label} rating")
          end
        end
      end
    end
  end

  # `:filled` draws unrated items as muted solid icons, `:outline` as line icons in the accent.
  def variants
    phlex do
      div(class: "flex flex-col gap-3") do
        %i[ filled outline ].each do |variant|
          div(class: "flex items-center gap-4") do
            span(class: "w-16 text-sm capitalize") { variant.to_s }
            Rating(default_value: 3, variant:, aria_label: "#{variant} rating")
          end
        end
      end
    end
  end

  # `orientation: :vertical` stacks the items and fills from the top down.
  def orientation
    phlex do
      div(class: "flex items-start gap-10") do
        Rating(default_value: 3, aria_label: "Horizontal rating")
        Rating(default_value: 3, orientation: :vertical, aria_label: "Vertical rating")
        Rating(default_value: 3.5, step: 0.5, orientation: :vertical, variant: :outline, aria_label: "Vertical half-step")
      end
    end
  end

  # `size:` takes pixels or any CSS length ("1em" follows the text); the padding grows with it.
  def sizes
    phlex do
      div(class: "flex flex-col items-start gap-3") do
        Rating(default_value: 4, size: 16, aria_label: "16px rating")
        Rating(default_value: 4, aria_label: "Default rating")
        Rating(default_value: 4, size: 40, aria_label: "40px rating")
        Rating(default_value: 4, size: "1em", class: "text-lg", aria_label: "Text-relative rating")
      end
    end
  end

  # `step:` sets the granularity of clicks and the hover preview; a finer value renders exactly.
  def fractions
    phlex do
      div(class: "flex flex-col gap-3") do
        { "Halves" => [ 3.5, 0.5 ], "Quarters" => [ 3.75, 0.25 ] }.each do |label, (value, step)|
          div(class: "flex items-center gap-4") do
            span(class: "w-16 text-sm") { label }
            Rating(default_value: value, step:, aria_label: "#{label} rating")
          end
        end
      end
    end
  end

  # The accent is inherited: a text-* class recolors fill and outline together.
  def color
    phlex do
      div(class: "flex flex-col items-start gap-3") do
        Rating(default_value: 4, aria_label: "Primary rating")
        Rating(default_value: 4, class: "text-warning-emphasis", aria_label: "Warning rating")
        Rating(default_value: 4, class: "text-error-emphasis", aria_label: "Error rating")
        Rating(default_value: 4, variant: :outline, class: "text-success-emphasis", aria_label: "Success rating")
      end
    end
  end

  # @label Read only
  # `read_only: true` renders a non-interactive display exposed as one labelled image
  # ("4.3 out of 5"); pair it with a small step for averages.
  def read_only
    phlex do
      div(class: "flex flex-col gap-3") do
        div(class: "flex items-center gap-3") do
          Rating(value: 4.3, step: 0.1, size: 32, read_only: true)
          span(class: "text-sm font-medium") { "4.3" }
          span(class: "text-foreground-muted text-sm") { "(1,284 reviews)" }
        end
        div(class: "flex flex-col gap-1.5") do
          { "Value for money" => 4.5, "Build quality" => 4, "Battery life" => 3.5 }.each do |label, score|
            div(class: "flex items-center gap-3") do
              span(class: "text-foreground-muted w-32 text-sm") { label }
              Rating(value: score, step: 0.5, size: 16, read_only: true)
            end
          end
        end
      end
    end
  end

  # @label Controlled with labels
  # `ui--rating:hover-change` reports the rating under the pointer and `ui--rating:change` the
  # committed one - here a caption follows them. `clearable:` lets a second click reset to 0.
  def feedback
    phlex do
      div(class: "flex flex-col items-center gap-2", data: { demo: "feedback" }) do
        span(id: "feedback-label", class: "text-foreground-intense text-sm font-medium") { "How was your experience?" }
        Rating(clearable: true, size: 32, aria_labelledby: "feedback-label")
        span(class: "text-foreground-muted h-5 text-sm", data: { caption: "" })
      end
      script(type: "module") do
        raw safe(<<~JS)
          const demo = document.querySelector("[data-demo=feedback]")
          const caption = demo.querySelector("[data-caption]")
          const labels = [ "Terrible", "Poor", "Average", "Good", "Excellent" ]
          let committed = 0
          const show = value => caption.textContent = value > 0 ? labels[Math.ceil(value) - 1] : ""
          demo.addEventListener("ui--rating:change", ({ detail }) => show(committed = detail.value))
          demo.addEventListener("ui--rating:hover-change", ({ detail }) => show(detail.value ?? committed))
        JS
      end
    end
  end

  # @label In a form
  # `name:` renders a hidden input with the current value, so the rating submits with the form.
  # Name the group with aria_labelledby.
  def form
    phlex do
      form(class: "flex w-full max-w-70 flex-col gap-4", data: { demo: "form" }) do
        div do
          span(id: "score-label", class: "text-foreground-intense mb-1.5 block text-sm font-medium select-none") { "Rate your stay" }
          Rating(name: "score", aria_labelledby: "score-label")
          p(class: "text-foreground-muted mt-1 text-xs") { "Submits as a hidden input named score." }
        end
        Button(type: "submit", class: "self-start") { "Send review" }
        output(class: "text-foreground-muted font-mono text-xs")
      end
      script(type: "module") do
        raw safe(<<~JS)
          const form = document.querySelector("[data-demo=form]")
          form.addEventListener("submit", event => {
            event.preventDefault()
            form.querySelector("output").textContent = `score=${new FormData(form).get("score")}`
          })
        JS
      end
    end
  end

  # @label RTL
  # The first item sits on the right and the fill runs right to left; ←/→ swap roles.
  def rtl
    phlex do
      I18n.with_locale(:ar) do
        div(dir: "rtl", class: "flex flex-col items-start gap-2") do
          span(class: "text-sm font-medium") { "قيّم هذا المنتج" }
          Rating(default_value: 3.5, step: 0.5)
        end
      end
    end
  end
end
