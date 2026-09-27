# A row of Toggles that tracks which are pressed - one at a time, or several with `multiple:`.
#
# The row is one tab stop; the arrow keys move between toggles.
#
# @label Toggle Group
# @logical_path Actions & Inputs
# @component UI::ToggleGroup
# @display width wide
class UI::ToggleGroupPreview < UI::BasePreview
  # Props not in the Usage form (data, render blocks, generated ids): see ui_components:preview_params
  UNLISTED_PROPS = %i[ default_value ].freeze

  ALIGNMENTS = { left: "Align left", center: "Align center", right: "Align right" }.freeze
  ALIGNMENT_TOGGLES = proc do
    ALIGNMENTS.each do |value, text|
      Toggle(value:, aria_label: text) { |toggle| Button(**toggle, variant: :ghost, icon: true) { Icon(:"align_#{value}") } }
    end
  end

  # @label Usage
  # @param multiple [Boolean] toggle
  # @param orientation [Symbol] select {{ choices_for UI::ToggleGroup, :orientation }}
  # @param disabled [Boolean] toggle
  # @param value text
  # @param loop_focus [Boolean] toggle
  # @param name text
  # @param include_hidden [Boolean] toggle
  def default(multiple: false, orientation: :horizontal, disabled: false, value: nil, loop_focus: true, name: nil, include_hidden: false)
    phlex do
      ToggleGroup(multiple:, orientation:, disabled:, loop_focus:, include_hidden:, **given(value:, name:), default_value: [ "center" ], aria_label: "Text alignment") do
        instance_exec(&ALIGNMENT_TOGGLES)
      end
    end
  end

  # @label Single selection
  # Pressing one releases the other.
  def single
    phlex do
      ToggleGroup(default_value: [ "center" ], aria_label: "Text alignment") { instance_exec(&ALIGNMENT_TOGGLES) }
    end
  end

  # @label Multiple selection
  def multiple
    phlex do
      ToggleGroup(multiple: true, default_value: [ "bold" ], aria_label: "Text formatting") do
        { bold: "Bold", italic: "Italic", underline: "Underline" }.each do |value, text|
          Toggle(value:, aria_label: text) { |toggle| Button(**toggle, variant: :ghost, icon: true) { Icon(value) } }
        end
      end
    end
  end

  # @label Vertical orientation
  # Stacked, with ↑/↓ moving focus.
  def vertical
    phlex do
      ToggleGroup(orientation: :vertical, default_value: [ "left" ], aria_label: "Text alignment") { instance_exec(&ALIGNMENT_TOGGLES) }
    end
  end

  def disabled
    phlex do
      ToggleGroup(disabled: true, default_value: [ "center" ], aria_label: "Text alignment") { instance_exec(&ALIGNMENT_TOGGLES) }
    end
  end

  # @label Color swatches
  # Bare toggles styled as swatches; the pressed one gets a ring. `name:` submits the choice.
  def swatches
    swatches = { sage: [ "Sage", "#8fb478" ], terracotta: [ "Terracotta", "#cc8259" ], sand: [ "Sand", "#d9ba6e" ], blush: [ "Blush", "#db9385" ], denim: [ "Denim", "#7e9cc9" ] }

    phlex do
      div(class: "flex flex-col items-start gap-3", data: { demo: "swatches" }) do
        span(class: "text-foreground-muted text-sm") do
          plain "Color - "
          span(class: "text-foreground-intense font-medium", data: { demo: "color" }) { "Sage" }
        end
        ToggleGroup(name: "color", default_value: [ "sage" ], aria_label: "Swatch color", class: "gap-3") do
          swatches.each do |value, (name, color)|
            Toggle(value:, aria_label: name, style: "background-color: #{color}", data: { name: },
              class: "after:ring-border-inverse outline-ring relative size-4 cursor-pointer rounded-full outline-offset-2 transition-transform after:pointer-events-none after:absolute after:-inset-0.5 after:scale-50 after:rounded-full after:opacity-0 after:ring-1 after:transition after:duration-200 after:ease-[cubic-bezier(0.175,0.885,0.32,1.5)] active:scale-90 data-pressed:after:scale-100 data-pressed:after:opacity-100 motion-reduce:transition-none motion-reduce:after:transition-none")
          end
        end
      end
      script(type: "module") do
        raw safe(<<~JS)
          const demo = document.querySelector("[data-demo=swatches]")
          demo.addEventListener("ui--toggle-group:change", ({ detail: { value } }) => {
            const pressed = demo.querySelector(`[data-slot=toggle][value="${value[0]}"]`)
            demo.querySelector("[data-demo=color]").textContent = pressed ? pressed.dataset.name : "None"
          })
        JS
      end
    end
  end

  # @label RTL
  # ←/→ follow the reading direction.
  def rtl
    phlex do
      ToggleGroup(dir: "rtl", default_value: [ "right" ], aria_label: "محاذاة النص") { instance_exec(&ALIGNMENT_TOGGLES) }
    end
  end
end
