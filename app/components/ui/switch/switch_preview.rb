# An on/off toggle for a setting that applies right away - a native checkbox with role="switch".
#
# It renders only the track - wrap it with its text in a <label>.
#
# @label Switch
# @logical_path Actions & Inputs
# @component UI::Switch
# @display width wide
class UI::SwitchPreview < UI::BasePreview
  # Props not in the Usage form (data, render blocks, generated ids): see ui_components:preview_params
  UNLISTED_PROPS = %i[ invalid unchecked_value ].freeze

  # @label Usage
  # @param size [Symbol] select {{ choices_for UI::Switch, :size }}
  # @param checked [Boolean] toggle
  # @param disabled [Boolean] toggle
  # @param value text
  def default(size: :md, checked: true, disabled: false, value: nil)
    phlex do
      label(class: "flex items-center gap-2.5 text-sm select-none") do
        Switch(size:, checked:, disabled:, **given(value:))
        plain "Airplane mode"
      end
    end
  end

  # `size:` scales the track and thumb together.
  def sizes
    phlex do
      div(class: "flex flex-wrap items-center gap-6 text-sm select-none") do
        label(class: "flex items-center gap-2 text-xs") { Switch(size: :sm, checked: true); plain "Small" }
        label(class: "flex items-center gap-2.5") { Switch(size: :md, checked: true); plain "Medium" }
        label(class: "flex items-center gap-2.5 text-base") { Switch(size: :lg, checked: true); plain "Large" }
      end
    end
  end

  # Off, on, disabled either way, and the error state (`aria_invalid:` or inside an invalid Field).
  def states
    phlex do
      div(class: "flex flex-wrap items-center gap-6 text-sm select-none") do
        label(class: "flex items-center gap-2.5") { Switch(); plain "Off" }
        label(class: "flex items-center gap-2.5") { Switch(checked: true); plain "On" }
        label(class: "text-foreground-muted flex items-center gap-2.5") { Switch(disabled: true); plain "Disabled" }
        label(class: "text-foreground-muted flex items-center gap-2.5") { Switch(disabled: true, checked: true); plain "Disabled on" }
        label(class: "flex items-center gap-2.5") { Switch(aria_invalid: true); plain "Error" }
      end
    end
  end

  # @label With a label and description
  # A settings row: the whole card is one click target.
  def with_label
    phlex do
      label(class: "border-border flex max-w-sm items-center justify-between gap-4 rounded-xl border p-5 select-none") do
        span(class: "flex flex-col") do
          span(class: "text-foreground-intense font-medium") { "Marketing emails" }
          span(class: "text-foreground-muted text-sm") { "Receive tips, product updates, and occasional offers." }
        end
        Switch(checked: true)
      end
    end
  end

  # @label Reacting to changes
  # It's a checkbox: listen for `change` (here a tiny Stimulus-free script updates the text).
  # `unchecked_value:` submits "0" when it's off.
  def controlled
    phlex do
      label(class: "text-foreground flex items-center gap-2.5 text-sm select-none") do
        Switch(name: "wifi", value: "1", unchecked_value: "0", checked: true, data: { demo: "wifi" })
        span { plain "Wi-Fi is "; span(data: { demo: "wifi-state" }) { "on" } }
      end
      script(type: "module") do
        raw safe(<<~JS)
          const wifi = document.querySelector("[data-demo=wifi]")
          wifi.addEventListener("change", () => document.querySelector("[data-demo=wifi-state]").textContent = wifi.checked ? "on" : "off")
        JS
      end
    end
  end

  # @label RTL
  # The thumb slides toward the start edge.
  def rtl
    phlex do
      div(dir: "rtl", class: "flex items-center gap-6 text-sm select-none") do
        label(class: "flex items-center gap-2.5") { Switch(checked: true); plain "الوضع الليلي" }
        label(class: "flex items-center gap-2.5") { Switch(); plain "الإشعارات" }
      end
    end
  end
end
