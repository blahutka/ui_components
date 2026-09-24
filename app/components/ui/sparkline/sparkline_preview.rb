# A compact interactive inline chart for showing a trend at a glance.
#
# Sparkline owns the series and active point. SparklineChart draws a line, area,
# or columns; SparklineValue and SparklineLabel follow the hovered reading.
#
# @label Sparkline
# @logical_path Data Display
# @component UI::Sparkline
# @display width wide
class UI::SparklinePreview < UI::BasePreview
  DATA = [8, 14, 10, 18, 15, 22, 19, 27, 24, 31].freeze
  DAYS = %w[Mon Tue Wed Thu Fri Sat Sun Mon].freeze
  COLOR_OPTIONS = {
    primary: "var(--primary)",
    success: "var(--success-emphasis)",
    error: "var(--error-emphasis)",
    warning: "var(--warning-emphasis)",
    info: "var(--info-emphasis)",
    purple: "#a855f7"
  }.freeze

  # @label Usage
  # A stroke-only line by default. Hover or touch to reveal the nearest point.
  # @param variant [Symbol] select "Chart style" { choices: [line, area, column] }
  # @param fill [Boolean] toggle "Gradient fill (line only)"
  # @param curve [Float] range { min: 0, max: 1, step: 0.1 }
  # @param height [Integer] range { min: 32, max: 96, step: 8 }
  # @param color [Symbol] select "Chart color" { choices: [primary, success, error, warning, info, purple] }
  # @param tooltip [Boolean]
  # @param label [Boolean] toggle "Label"
  # @param value_preview [Boolean] toggle "Label value"
  def default(variant: :line, fill: true, curve: 0.2, height: 56, color: :info, tooltip: true, label: true, value_preview: true)
    phlex do
      Sparkline(data: [8, 15, 11, 20, 16, 26, 49.1], labels: %w[Mon Tue Wed Thu Fri Sat Sun],
                color: COLOR_OPTIONS.fetch(color.to_sym, COLOR_OPTIONS[:primary]), class: "w-72 max-w-full") do
        SparklineLabel() if label
        SparklineValue(class: "text-2xl") if value_preview
        SparklineChart(variant:, fill:, curve:, tooltip:, height:, aria_label: "Trend over the last 10 periods")
      end
    end
  end

  # Area fills to a real baseline. The second series crosses zero, so positive
  # and negative magnitudes occupy opposite sides of the reference line.
  def area
    phlex do
      div(class: "flex w-72 max-w-full flex-col gap-6") do
        Sparkline(data: [6, 11, 8, 16, 13, 22, 18, 27]) do
          SparklineChart(variant: :area, height: 56, aria_label: "Signups over 8 weeks")
        end
        Sparkline(data: [3, -4, 2, 6, -2, -6, 4, 1]) do
          SparklineChart(variant: :area, height: 56, aria_label: "Net change over 8 weeks")
        end
      end
    end
  end

  # @label Filled line
  # A line fill fades to the chart edge instead of expressing a semantic baseline.
  def filled_line
    phlex do
      div(class: "flex w-72 max-w-full flex-col gap-6") do
        Sparkline(data: DATA) { SparklineChart(height: 56, aria_label: "Line") }
        Sparkline(data: DATA) { SparklineChart(fill: true, height: 56, aria_label: "Gradient-filled line") }
      end
    end
  end

  # Columns pivot on the baseline. Hovering highlights the active bucket and
  # floats its label and value.
  def columns
    phlex do
      div(class: "flex w-72 max-w-full flex-col gap-6") do
        Sparkline(data: [4, 9, 6, 12, 8, 15, 11, 18], labels: DAYS) do
          SparklineChart(variant: :column, height: 56, tooltip: true, aria_label: "Daily visits")
        end
        Sparkline(data: [6, -7, 9, -4, 8, -9, 5, -6], labels: DAYS) do
          SparklineChart(variant: :column, height: 56, tooltip: true, aria_label: "Net change per day")
        end
      end
    end
  end

  # `curve:` runs from straight segments at 0 to fully rounded peaks at 1.
  def smoothing
    phlex do
      div(class: "flex w-72 max-w-full flex-col gap-6") do
        Sparkline(data: DATA) { SparklineChart(curve: 0, aria_label: "Straight segments") }
        Sparkline(data: DATA) { SparklineChart(curve: 1, aria_label: "Fully smoothed") }
      end
    end
  end

  # `stroke_width:` stays crisp at any chart width because the SVG stroke does
  # not scale with its view box.
  def line_weight
    phlex do
      div(class: "flex w-72 max-w-full flex-col gap-6") do
        Sparkline(data: DATA) { SparklineChart(stroke_width: 1, aria_label: "Thin line") }
        Sparkline(data: DATA) { SparklineChart(stroke_width: 3, aria_label: "Thick line") }
      end
    end
  end

  # Labels and formatted values are shown in the tooltip at the hovered point.
  def tooltip
    phlex do
      Sparkline(data: [8, 15, 11, 20, 16, 26, 22], labels: %w[Mon Tue Wed Thu Fri Sat Sun],
                class: "w-72 max-w-full") do
        SparklineChart(variant: :area, height: 56, tooltip: true, aria_label: "Weekly requests")
      end
    end
  end

  # @label Value headline
  # Value and label show the last reading at rest and follow the chart on hover.
  def value_headline
    phlex do
      Sparkline(data: [198_120, 201_540, 199_880, 205_300, 208_770, 214_260, 222_240],
                labels: ["Nov 11", "Nov 12", "Nov 13", "Nov 14", "Nov 15", "Nov 16", "Nov 17"],
                class: "w-72 max-w-full") do
        SparklineLabel()
        SparklineValue(class: "text-2xl")
        SparklineChart(fill: true, height: 56, tooltip: true, aria_label: "Active users this week")
      end
    end
  end

  # Theme tokens or any CSS color drive the line, fill, marker, columns and swatch.
  def colors
    phlex do
      div(class: "flex w-72 max-w-full flex-col gap-5") do
        Sparkline(data: [6, 12, 9, 16, 14, 22, 20, 28], color: "var(--success-emphasis)") do
          SparklineChart(variant: :area, aria_label: "Revenue")
        end
        Sparkline(data: [28, 22, 25, 16, 19, 12, 14, 8], color: "var(--error-emphasis)") do
          SparklineChart(variant: :area, aria_label: "Churn")
        end
        Sparkline(data: [10, 14, 11, 15, 13, 18, 15, 19], color: "var(--warning-emphasis)") do
          SparklineChart(variant: :line, aria_label: "Latency")
        end
        Sparkline(data: [8, 16, 12, 22, 18, 26, 24, 32], color: "#a855f7") do
          SparklineChart(variant: :line, fill: true, aria_label: "Engagement")
        end
        Sparkline(data: [5, 11, 8, 14, 10, 18, 13, 21], color: "var(--info-emphasis)") do
          SparklineChart(variant: :column, aria_label: "Orders")
        end
      end
    end
  end

  # @label RTL
  # The series and pointer mapping mirror, while labels and values retain their
  # natural reading direction.
  def rtl
    phlex do
      div(dir: "rtl", class: "flex w-72 max-w-full flex-col gap-6") do
        Sparkline(data: [8, 14, 11, 20, 16, 26, 22], labels: %w[السبت الأحد الاثنين الثلاثاء الأربعاء الخميس الجمعة]) do
          SparklineLabel()
          SparklineValue(class: "text-2xl")
          SparklineChart(variant: :area, height: 56, tooltip: true, aria_label: "الاتجاه الأسبوعي")
        end
        Sparkline(data: [4, 9, 6, 12, 8, 15, 11]) do
          SparklineChart(variant: :column, height: 56, aria_label: "الأعمدة الأسبوعية")
        end
      end
    end
  end
end
