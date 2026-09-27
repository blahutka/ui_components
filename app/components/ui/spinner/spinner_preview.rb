# A spinning indicator that shows a loading state.
#
# A small, self-contained indicator for compact, in-place waits: a button, an icon button, a
# small overlay. Sized by font-size (set a text-* class or inherit 1em), and `current_color:`
# makes it take the surrounding text color. It animates with SVG SMIL - no JavaScript.
#
# @label Spinner
# @logical_path Status & Feedback
# @component UI::Spinner
# @display width wide
class UI::SpinnerPreview < UI::BasePreview
  # @label Usage
  # @param variant [Symbol] select {{ choices_for UI::Spinner, :variant }}
  # @param size [Symbol] select "Font size" {{ FONT_SIZES }}
  # @param current_color [Boolean] toggle "Inherit the text color (violet here)"
  def default(variant: :circular, size: :"text-[2.5rem]", current_color: false)
    phlex do
      span(class: "text-violet-500") { Spinner(variant:, current_color:, class: size.to_s) }
    end
  end

  # Three shapes: circular, dots and sparkle. Under prefers-reduced-motion each holds a
  # static frame instead of spinning.
  def variants
    phlex do
      div(class: "flex items-center gap-10") do
        %i[ circular dots sparkle ].each do |variant|
          div(class: "flex flex-col items-center gap-3") do
            Spinner(variant:)
            span(class: "text-foreground-muted text-xs") { variant.to_s }
          end
        end
      end
    end
  end

  # Sized by font-size, so a text-* utility scales it - there's no size prop.
  def sizing
    phlex do
      div(class: "flex items-end gap-8") do
        %w[ text-xl text-3xl text-5xl text-7xl ].each { |size| Spinner(class: size) }
      end
    end
  end

  # The primary accent by default; `current_color: true` inherits the surrounding text color.
  def color
    phlex do
      div(class: "flex items-center gap-8 text-4xl") do
        Spinner()
        %w[ text-violet-500 text-success-emphasis text-error-emphasis ].each do |color|
          span(class: color) { Spinner(current_color: true) }
        end
      end
    end
  end

  # @label In a button
  # A submit button shows a spinner while the action runs - `current_color:` matches the
  # label and `text-[1.2em]` scales with the button. The second pairs the sparkle variant
  # with an "Ask AI" affordance.
  def in_button
    phlex do
      div(class: "flex flex-wrap items-center justify-center gap-4") do
        Button(class: "min-w-34", data: { demo: "save" }) do
          Spinner(current_color: true, class: "text-[1.2em]", hidden: true)
          span { "Save changes" }
        end
        Button(variant: :outline, class: "rounded-full", data: { demo: "ask" }) do
          Spinner(variant: :sparkle, current_color: true, class: "text-lg", hidden: true, data: { icon: "start" })
          Icon(:sparkle, stroke_width: 1.75, data: { icon: "start" })
          span { "Ask AI" }
        end
      end
      script(type: "module") do
        raw safe(<<~JS)
          const busy = (button, label, ms) => {
            const [spinner, ...rest] = button.children
            const text = button.querySelector("span:last-child")
            const idle = text.textContent
            button.disabled = true
            spinner.hidden = false
            rest.filter(el => el.tagName === "svg").forEach(el => el.toggleAttribute("hidden", true))
            text.textContent = label
            setTimeout(() => {
              button.disabled = false
              spinner.hidden = true
              rest.forEach(el => el.toggleAttribute("hidden", false))
              text.textContent = idle
            }, ms)
          }
          document.querySelector("[data-demo=save]").addEventListener("click", ({ currentTarget }) => busy(currentTarget, "Saving…", 1800))
          document.querySelector("[data-demo=ask]").addEventListener("click", ({ currentTarget }) => busy(currentTarget, "Thinking…", 5000))
        JS
      end
    end
  end

  # @label Refresh button
  # In an icon button, swap the icon for a spinner while the action is in flight - the button
  # keeps its size, so the layout never jumps.
  def refresh
    phlex do
      Button(variant: :outline, icon: true, aria_label: "Refresh data", data: { demo: "refresh" }) do
        Icon(:refresh, stroke_width: 1.75)
        Spinner(variant: :dots, current_color: true, class: "text-[1.25em]", hidden: true)
      end
      script(type: "module") do
        raw safe(<<~JS)
          document.querySelector("[data-demo=refresh]").addEventListener("click", ({ currentTarget: button }) => {
            const [icon, spinner] = button.children
            button.disabled = true
            icon.toggleAttribute("hidden", true)
            spinner.hidden = false
            setTimeout(() => {
              button.disabled = false
              icon.toggleAttribute("hidden", false)
              spinner.hidden = true
            }, 1500)
          })
        JS
      end
    end
  end

  # @label Loading a panel
  # Show a centered spinner while a region fetches, then swap in the content.
  def panel
    phlex do
      div(class: "border-border bg-background w-72 rounded-xl border p-5", data: { demo: "panel" }) do
        div(class: "flex h-28 items-center justify-center", data: { state: "loading" }) { Spinner(class: "text-4xl") }
        div(class: "flex h-28 flex-col justify-between", data: { state: "ready" }, hidden: true) do
          div do
            p(class: "text-foreground-intense font-semibold") { "Production" }
            p(class: "text-success-emphasis text-sm") { "All systems operational" }
            p(class: "text-foreground-muted mt-1 text-xs") { "Synced just now" }
          end
          Button(variant: :soft, size: :sm, class: "self-start") do
            Icon(:refresh, stroke_width: 1.75, data: { icon: "start" })
            plain "Reload"
          end
        end
      end
      script(type: "module") do
        raw safe(<<~JS)
          const panel = document.querySelector("[data-demo=panel]")
          const [loading, ready] = panel.children
          const reload = () => {
            loading.hidden = false
            ready.hidden = true
            setTimeout(() => { loading.hidden = true; ready.hidden = false }, 1600)
          }
          ready.querySelector("button").addEventListener("click", reload)
          reload()
        JS
      end
    end
  end

  # @label RTL
  # Direction-agnostic; inside a button the spinner leads the label on the correct side.
  def rtl
    phlex do
      div(dir: "rtl", class: "flex justify-center") do
        Button(disabled: true, class: "min-w-34") do
          Spinner(current_color: true, class: "text-[1.2em]")
          plain "حفظ التغييرات"
        end
      end
    end
  end
end
