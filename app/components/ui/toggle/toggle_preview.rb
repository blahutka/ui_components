# A two-state button (aria-pressed) with no look of its own: hand its attributes to a Button,
# which paints the pressed state.
#
# @label Toggle
# @logical_path Actions & Inputs
# @component UI::Toggle
# @display width wide
class UI::TogglePreview < UI::BasePreview
  # @label Usage
  # @param pressed [Boolean] toggle
  # @param disabled [Boolean] toggle
  # @param variant [Symbol] select { choices: [outline, ghost, soft] }
  def default(pressed: false, disabled: false, variant: :outline)
    phlex do
      Toggle(pressed:, disabled:, aria_label: "Bold") { |toggle| Button(**toggle, variant:, icon: true) { Icon(:bold) } }
    end
  end

  # @label Composing with Button
  # A block that takes an argument receives the toggle's attributes (Appica's `render` prop).
  def composing
    phlex do
      div(class: "flex items-center gap-2") do
        Toggle(pressed: true, aria_label: "Bold") { |toggle| Button(**toggle, variant: :outline, icon: true) { Icon(:bold) } }
        Toggle(aria_label: "Italic") { |toggle| Button(**toggle, variant: :outline, icon: true) { Icon(:italic) } }
        Toggle(aria_label: "Underline") { |toggle| Button(**toggle, variant: :outline, icon: true) { Icon(:underline) } }
      end
    end
  end

  def states
    phlex do
      div(class: "flex flex-wrap items-center gap-3") do
        Toggle { |toggle| Button(**toggle, variant: :outline) { "Off" } }
        Toggle(pressed: true) { |toggle| Button(**toggle, variant: :outline) { "Pressed" } }
        Toggle(disabled: true) { |toggle| Button(**toggle, variant: :outline) { "Disabled" } }
      end
    end
  end

  # @label Reacting to changes
  # `ui--toggle:change` carries { pressed }; here it swaps the icon, variant, label and helper text.
  def controlled
    phlex do
      div(class: "border-border flex w-full max-w-74 items-center justify-between gap-4 rounded-xl border p-4", data: { demo: "notifications" }) do
        div(class: "flex flex-col gap-0.5") do
          span(class: "text-foreground-intense text-sm font-medium") { "Notifications" }
          span(class: "text-foreground-muted text-xs", data: { demo: "hint" }) { "You'll be notified about new activity" }
        end
        Toggle(pressed: true, aria_label: "Mute notifications") do |toggle|
          Button(**toggle, variant: :primary, icon: true) do
            Icon(:bell, data: { demo: "on" })
            Icon(:bell_off, data: { demo: "off" }, hidden: true)
          end
        end
      end
      script(type: "module") do
        raw safe(<<~JS)
          const card = document.querySelector("[data-demo=notifications]")
          card.addEventListener("ui--toggle:change", ({ target, detail: { pressed } }) => {
            card.querySelector("[data-demo=hint]").textContent = pressed ? "You'll be notified about new activity" : "All notifications are paused"
            target.setAttribute("aria-label", pressed ? "Mute notifications" : "Enable notifications")
            target.classList.toggle("bg-primary", pressed)
            target.classList.toggle("text-primary-foreground", pressed)
            target.classList.toggle("before:bg-background-muted", !pressed)
            card.querySelector("[data-demo=on]").hidden = !pressed
            card.querySelector("[data-demo=off]").hidden = pressed
          })
        JS
      end
    end
  end

  # @label RTL
  def rtl
    phlex do
      div(dir: "rtl", class: "flex items-center gap-2") do
        Toggle(pressed: true) { |toggle| Button(**toggle, variant: :outline) { "عريض" } }
        Toggle { |toggle| Button(**toggle, variant: :outline) { "مائل" } }
      end
    end
  end
end
