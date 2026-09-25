# A value or a range picked along a track, with a value tooltip.
#
# @label Slider
# @logical_path Actions & Inputs
# @component UI::Slider
# @display width wide
class UI::SliderPreview < UI::BasePreview
  # @label Usage
  # @param value number
  # @param step number
  # @param tooltip [Symbol] select { choices: [auto, always, never] }
  # @param disabled [Boolean] toggle
  def default(value: 50, step: 1, tooltip: :auto, disabled: false)
    phlex { Slider(default_value: value.to_f, step: step.to_f, tooltip:, disabled:, thumb_aria_label: "Volume", class: "max-w-70") }
  end

  # An array value renders a thumb per entry; name each end with `thumb_aria_label:`.
  def range
    phlex { Slider(default_value: [ 25, 75 ], thumb_aria_label: %w[ Minimum Maximum ], class: "max-w-70") }
  end

  # `step:` sets the granularity; Shift / Page Up·Down move by `large_step:`.
  def steps
    phlex { Slider(default_value: 40, step: 10, tooltip: :always, thumb_aria_label: "Amount", class: "max-w-70 mt-6") }
  end

  # @label Tooltip visibility
  def tooltip
    phlex do
      div(class: "flex w-full max-w-70 flex-col gap-8 pt-6") do
        Slider(default_value: 30, tooltip: :auto, thumb_aria_label: "Auto")
        Slider(default_value: 50, tooltip: :always, thumb_aria_label: "Always")
        Slider(default_value: 70, tooltip: :never, thumb_aria_label: "Never")
      end
    end
  end

  # `format:` takes Intl.NumberFormat options for the tooltip and aria-valuetext.
  def formatted
    phlex do
      div(class: "flex w-full max-w-70 flex-col gap-10 pt-6") do
        Slider(default_value: 0.4, max: 1, step: 0.05, format: { style: "percent" }, tooltip: :always, thumb_aria_label: "Opacity")
        Slider(default_value: [ 120, 480 ], min: 0, max: 1000, step: 10, format: { style: "currency", currency: "USD", maximum_fraction_digits: 0 }, tooltip: :always, thumb_aria_label: %w[ From To ])
      end
    end
  end

  def vertical
    phlex do
      div(class: "flex h-48 items-center gap-10") do
        Slider(orientation: :vertical, default_value: 60, thumb_aria_label: "Volume")
        Slider(orientation: :vertical, default_value: [ 20, 80 ], thumb_aria_label: %w[ Min Max ])
      end
    end
  end

  # @label Reacting to changes
  # `ui--slider:change` fires while moving - three sliders drive an RGB swatch.
  def controlled
    phlex do
      div(class: "flex w-full max-w-90 items-center gap-6", data: { demo: "rgb" }) do
        div(class: "flex w-full max-w-64 flex-col gap-4") do
          { r: 99, g: 102, b: 241 }.each do |channel, value|
            div(class: "flex items-center gap-3") do
              span(class: "text-foreground-muted w-3 text-sm font-medium") { channel.to_s.upcase }
              Slider(default_value: value, max: 255, tooltip: :never, thumb_aria_label: "#{channel.upcase} channel", class: "flex-1", data: { channel: })
              span(class: "text-foreground-muted w-8 text-end text-sm tabular-nums", data: { output: channel }) { value.to_s }
            end
          end
        end
        div(class: "flex shrink-0 flex-col items-center gap-2") do
          div(class: "border-border-muted size-20 rounded-lg border", style: "background-color: #6366f1", data: { demo: "swatch" })
          span(class: "text-foreground-muted font-mono text-xs uppercase", data: { demo: "hex" }) { "#6366f1" }
        end
      end
      script(type: "module") do
        raw safe(<<~JS)
          const demo = document.querySelector("[data-demo=rgb]")
          const rgb = { r: 99, g: 102, b: 241 }
          demo.addEventListener("ui--slider:change", ({ target, detail: { value } }) => {
            const channel = target.dataset.channel
            rgb[channel] = value
            demo.querySelector(`[data-output=${channel}]`).textContent = value
            const hex = "#" + [ rgb.r, rgb.g, rgb.b ].map(c => c.toString(16).padStart(2, "0")).join("")
            demo.querySelector("[data-demo=swatch]").style.backgroundColor = hex
            demo.querySelector("[data-demo=hex]").textContent = hex
          })
        JS
      end
    end
  end

  def disabled
    phlex { Slider(default_value: 50, disabled: true, thumb_aria_label: "Disabled", class: "max-w-70") }
  end

  # @label RTL
  # The fill grows from the right and ←/→ follow the reading direction.
  def rtl
    phlex { div(dir: "rtl", class: "w-full max-w-70") { Slider(default_value: [ 20, 60 ], thumb_aria_label: %w[ الأدنى الأعلى ]) } }
  end
end
