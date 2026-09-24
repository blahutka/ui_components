# The visualization inside Sparkline. Line and area variants are server-rendered
# SVG; columns use positioned divs. Stimulus adds only pointer state and overlays.
class UI::SparklineChart < UI::Base
  VARIANTS = %i[ line area column ].freeze
  POINTER_ACTIONS = "pointerdown->ui--sparkline#activate pointermove->ui--sparkline#activate " \
    "pointerleave->ui--sparkline#clear pointerup->ui--sparkline#release pointercancel->ui--sparkline#release"

  def initialize(variant: :line, curve: 0.5, fill: false, baseline: 0, height: 48, stroke_width: 2,
                 indicator: true, tooltip: false, **attributes)
    @variant = VARIANTS.include?(variant.to_sym) ? variant.to_sym : :line
    @curve = curve.to_f.clamp(0, 1)
    @fill = fill
    @baseline = baseline.to_f
    @height = height.to_f
    @stroke_width = stroke_width.to_f
    @indicator = indicator
    @tooltip = tooltip
    @attributes = attributes
  end

  def before_template(&content)
    @custom_tooltip = content&.arity == 1
    super
  end

  def view_template(&)
    return if sparkline.data.empty?

    div(**mix(chart_attributes, @attributes.except(:class, :style)),
        class: cn("relative w-full", override: @attributes[:class]), style: chart_style) do
      @variant == :column ? render_columns : render_svg
      render_indicator if @indicator && @variant != :column
      render_tooltip(&) if @tooltip || @custom_tooltip
    end
  end

  private
    def sparkline = consume(:ui_sparkline, component: "Sparkline")

    def chart_attributes
      {
        role: @attributes.fetch(:role, "img"),
        aria: { label: @attributes[:aria_label] || "#{@variant} chart" },
        data: {
          slot: "sparkline-chart",
          variant: @variant,
          indicator: @indicator.to_s,
          points: marker_points.to_json,
          action: interactive? ? POINTER_ACTIONS : nil
        }
      }
    end

    def chart_style
      [ "height: #{number(@height)}px", ("touch-action: pan-y" if interactive?), @attributes[:style] ].compact.join("; ")
    end

    def interactive? = @indicator || @tooltip || @custom_tooltip

    def render_svg
      geometry = line_geometry
      gradient_id = "sparkline-gradient-#{SecureRandom.hex(4)}"
      show_fill = @variant == :area || @fill

      svg(data: { slot: "sparkline-svg" }, width: "100%", height: number(@height), viewBox: "0 0 100 #{number(@height)}",
          preserveAspectRatio: "none", aria_hidden: "true", class: "block overflow-visible rtl:scale-x-[-1]") do |s|
        if show_fill && @variant == :line
          s.defs do
            s.linearGradient(id: gradient_id, x1: "0", y1: "0", x2: "0", y2: "1") do
              s.stop(offset: "0%", stop_color: "var(--sparkline-color)", stop_opacity: "0.3")
              s.stop(offset: "100%", stop_color: "var(--sparkline-color)", stop_opacity: "0")
            end
          end
        end

        if show_fill
          s.path(data: { slot: "sparkline-fill" }, d: geometry[:fill_path],
                 fill: (@variant == :line ? "url(##{gradient_id})" : "var(--sparkline-color)"),
                 fill_opacity: (@variant == :line ? "1" : "0.18"))
        end

        if geometry[:baseline_y]
          s.line(data: { slot: "sparkline-baseline" }, x1: "0", y1: geometry[:baseline_y], x2: "100", y2: geometry[:baseline_y],
                 class: "stroke-border", stroke_width: "1", vector_effect: "non-scaling-stroke")
        end

        s.path(data: { slot: "sparkline-line" }, d: geometry[:path], fill: "none", stroke: "var(--sparkline-color)",
               stroke_width: number(@stroke_width), stroke_linecap: "butt", stroke_linejoin: "round",
               vector_effect: "non-scaling-stroke")
      end
    end

    def render_columns
      geometry = column_geometry

      div(dir: "ltr", class: "flex h-full items-stretch gap-[3%] rtl:flex-row-reverse") do
        geometry[:bars].each do |bar|
          div(class: "rounded-3xs data-active:bg-background-strong relative h-full flex-1",
              data: { "ui--sparkline-target": "column" }) do
            div(data: { slot: "sparkline-column" },
                class: cn("absolute inset-x-0 bg-(--sparkline-color) motion-safe:transition-all motion-safe:duration-300",
                          bar[:positive] ? "rounded-t-[min(var(--radius-3xs),35%)]" : "rounded-b-[min(var(--radius-3xs),35%)]"),
                style: "top: #{bar[:top]}%; height: #{bar[:size]}%")
          end
        end
      end

      span(aria_hidden: "true", data: { slot: "sparkline-baseline" },
           class: "bg-border pointer-events-none absolute inset-x-0 h-px -translate-y-1/2",
           style: "top: #{round(geometry[:base_frac] * 100)}%")
    end

    def render_indicator
      span(hidden: true, aria_hidden: "true", data: { "ui--sparkline-target": "guide" },
           class: "pointer-events-none absolute inset-y-0 w-px -translate-x-1/2 bg-(--sparkline-color) opacity-25 motion-safe:transition-[left] motion-safe:duration-150")
      span(hidden: true, aria_hidden: "true", data: { "ui--sparkline-target": "dot" },
           class: "ring-background pointer-events-none absolute size-2.5 -translate-x-1/2 -translate-y-1/2 rounded-full bg-(--sparkline-color) ring-2 motion-safe:transition-all motion-safe:duration-150")
    end

    def render_tooltip
      div(hidden: true, aria_hidden: "true", data: { slot: "sparkline-tooltip", "ui--sparkline-target": "tooltip" },
          class: "pointer-events-none absolute z-10 w-max -translate-x-1/2 -translate-y-full pb-2 motion-safe:transition-[left,top] motion-safe:duration-150") do
        if @custom_tooltip
          sparkline.data.each_index do |index|
            div(hidden: true, data: { index:, "ui--sparkline-target": "customTooltip" }) { yield sparkline.point(index) }
          end
        else
          div(class: "border-border-overlay bg-background text-foreground-intense rounded-2xs flex items-center gap-1.5 border px-2 py-1 text-xs whitespace-nowrap shadow-md") do
            span(aria_hidden: "true", class: "size-2.5 shrink-0 rounded-[3px] bg-(--sparkline-color)")
            span(hidden: sparkline.labels.nil?, class: "text-foreground-muted", data: { "ui--sparkline-target": "tooltipLabel" })
            span(class: "font-medium tabular-nums", data: { "ui--sparkline-target": "tooltipValue" })
          end
        end
      end
    end

    def line_geometry
      values = sparkline.data
      data_min, data_max = values.minmax
      lo = @variant == :area ? [ @baseline, data_min ].min : data_min
      hi = @variant == :area ? [ @baseline, data_max ].max : data_max
      span = hi - lo
      span = 1 if span.zero?
      inset = @stroke_width + 1
      plot = @height - inset * 2
      y_of = ->(value) { inset + (1 - (value - lo).fdiv(span)) * plot }

      points = values.each_with_index.map do |value, index|
        fraction = values.one? ? 0.5 : index.fdiv(values.length - 1)
        y = y_of.call(value)
        { x: round(fraction * 100), y: round(y), left_frac: fraction, top_frac: y / @height }
      end

      path = build_line_path(points)
      foot = @variant == :area ? round(y_of.call(@baseline)) : number(@height)
      {
        path:,
        fill_path: "#{path} L #{points.last[:x]} #{foot} L #{points.first[:x]} #{foot} Z",
        points:,
        baseline_y: (@variant == :area ? foot : nil)
      }
    end

    def column_geometry
      values = sparkline.data
      data_min, data_max = values.minmax
      lo = [ @baseline, data_min ].min
      hi = [ @baseline, data_max ].max
      span = hi - lo
      span = 1 if span.zero?
      base_frac = (hi - @baseline).fdiv(span)

      bars = values.each_with_index.map do |value, index|
        value_frac = (hi - value).fdiv(span)
        {
          top: round([ value_frac, base_frac ].min * 100),
          size: round((value_frac - base_frac).abs * 100),
          positive: value >= @baseline,
          left_frac: (index + 0.5).fdiv(values.length),
          top_frac: value_frac
        }
      end

      { bars:, base_frac: }
    end

    def marker_points
      @variant == :column ? column_geometry[:bars] : line_geometry[:points]
    end

    def build_line_path(points)
      path = "M #{points.first[:x]} #{points.first[:y]}"
      points.each_cons(2).with_index do |(point, next_point), index|
        previous = points[index - 1] || point
        following = points[index + 2] || next_point
        cp1x = point[:x] + ((next_point[:x] - previous[:x]) / 6.0) * @curve
        cp1y = point[:y] + ((next_point[:y] - previous[:y]) / 6.0) * @curve
        cp2x = next_point[:x] - ((following[:x] - point[:x]) / 6.0) * @curve
        cp2y = next_point[:y] - ((following[:y] - point[:y]) / 6.0) * @curve
        path << " C #{round(cp1x)} #{round(cp1y)}, #{round(cp2x)} #{round(cp2y)}, #{next_point[:x]} #{next_point[:y]}"
      end
      path
    end

    def round(value) = (value * 100).round / 100.0
    def number(value) = value.to_i == value ? value.to_i : value
end
