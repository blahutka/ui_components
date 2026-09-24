# A graphical display of a numeric value within a known range.
#
# A static measurement - disk usage, a score, remaining battery - as opposed to Progress,
# which tracks a task toward completion. MeterLabel names it, MeterValue prints the formatted
# number and MeterProgress draws the track. Pass `low:`, `high:` and `optimum:` and the fill
# colors itself green, amber or red.
#
# @label Meter
# @logical_path Status & Feedback
# @component UI::Meter
# @display width wide
class UI::MeterPreview < UI::BasePreview
  USAGE = { "Operations" => 32, "Marketing" => 64, "Infrastructure" => 94 }.freeze
  SKILLS = { "TypeScript" => 90, "React" => 82, "CSS" => 70, "Rust" => 38 }.freeze
  LEVELS = [ "Too weak", "Weak", "Fair", "Good", "Strong" ].freeze
  LOCK = "M5 13a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v6a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2zm6 3a1 1 0 1 0 2 0 1 1 0 0 0-2 0m-3-5V7a4 4 0 1 1 8 0v4"

  # @label Usage
  # A label, a formatted value and a track; `value:` is read against the default 0-100 range.
  # @param value number
  # @param label text
  # @param thresholds [Boolean] toggle "low: 40, high: 75, optimum: 10"
  def default(value: 64, label: "Storage", thresholds: false)
    zones = thresholds ? { low: 40, high: 75, optimum: 10 } : {}

    phlex do
      Meter(value: value.to_f, class: "w-72 max-w-full", **zones) do
        MeterLabel { label }
        MeterValue()
        MeterProgress()
      end
    end
  end

  # @label Status thresholds
  # With `low:`, `high:` and `optimum:` the fill colors by zone: green where optimum sits,
  # amber one zone away, red at the far end. `optimum: 10` marks low usage as healthy.
  def status
    phlex do
      div(class: "flex w-72 max-w-full flex-col gap-5") do
        USAGE.each do |label, value|
          Meter(value:, low: 40, high: 75, optimum: 10) do
            MeterLabel { label }
            MeterValue()
            MeterProgress()
          end
        end
      end
    end
  end

  # @label Formatting the value
  # `format:` takes Intl.NumberFormat options (in snake_case) - currency, a unit, and so on.
  # For full control give MeterValue a block that receives the formatted string.
  def formatting
    phlex do
      div(class: "flex w-72 max-w-full flex-col gap-6") do
        Meter(value: 1280, max: 2000, format: { style: :currency, currency: "USD" }, low: 1000, high: 1800, optimum: 0) do
          MeterLabel { "Monthly budget" }
          MeterValue()
          MeterProgress()
        end
        Meter(value: 3.4, max: 8, format: { style: :unit, unit: "gigabyte", maximum_fraction_digits: 1 }) do
          MeterLabel { "Backup size" }
          MeterValue { |formatted, _value| "#{formatted} of 8 GB" }
          MeterProgress()
        end
      end
    end
  end

  # @label Password strength (controlled)
  # Score the input as the user types and set the meter's value - the controller moves the
  # fill, recolors it by zone (`max: 4`, red → amber → green) and shows a word from `labels:`.
  def password_strength
    phlex do
      div(class: "flex w-72 max-w-full flex-col gap-2") do
        label(class: "relative block") do
          svg(viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "1.75", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true",
            class: "text-foreground-muted pointer-events-none absolute start-3 top-1/2 size-4.5 -translate-y-1/2") { |s| s.path(d: LOCK) }
          input(type: "password", id: "password-demo", autocomplete: "new-password", placeholder: "Choose a password", aria_label: "Password",
            class: "border-border-strong bg-background text-foreground h-10 w-full min-w-0 rounded-md border ps-9.5 pe-3.5 text-sm outline-none focus:border-transparent focus:ring-3 focus:ring-ring-input")
        end
        Meter(value: 0, max: 4, low: 2, high: 2, optimum: 4, aria_label: "Password strength", id: "password-meter",
          status_classes: { invalid: "bg-error-emphasis", suboptimum: "bg-warning-emphasis", optimum: "bg-success-emphasis" }) do
          MeterValue(labels: LEVELS, class: "text-foreground-muted text-xs")
          MeterProgress()
        end
      end
      script(type: "module") do
        raw safe(<<~JS)
          const score = value => {
            if (value.length < 3) return 0
            let score = 1
            if (value.length >= 10) score++
            if (/[A-Z]/.test(value) && /[a-z]/.test(value)) score++
            if (/[0-9]/.test(value) || /[^A-Za-z0-9]/.test(value)) score++
            return score
          }
          const meter = document.getElementById("password-meter")
          document.getElementById("password-demo").addEventListener("input", ({ target }) => {
            meter.setAttribute("data-ui--meter-value-value", score(target.value))
          })
        JS
      end
    end
  end

  # Drop MeterValue (and even MeterLabel) for a bare track; restyle the track height and the
  # label through `class:`.
  def minimal
    phlex do
      div(class: "flex w-64 max-w-full flex-col gap-3") do
        SKILLS.each do |label, value|
          Meter(value:, class: "gap-1") do
            MeterLabel(class: "text-foreground text-xs font-normal") { label }
            MeterProgress(class: "h-1")
          end
        end
      end
    end
  end

  # @label RTL
  # The label and value swap sides and the track fills from the right.
  def rtl
    phlex do
      div(dir: "rtl", class: "flex w-72 max-w-full flex-col gap-5") do
        Meter(value: 64) do
          MeterLabel { "التخزين" }
          MeterValue()
          MeterProgress()
        end
        Meter(value: 92, low: 40, high: 75, optimum: 10) do
          MeterLabel { "النطاق الترددي" }
          MeterValue()
          MeterProgress()
        end
      end
    end
  end
end
