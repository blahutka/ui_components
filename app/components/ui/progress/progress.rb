# The completion status of a task that takes a while - an upload, an import, an install.
# (For a static measurement use Meter; for an unknown duration, Loader or Spinner.)
#
#   Progress(value: 60) do
#     ProgressLabel { "Uploading" }
#     ProgressValue()
#   end
#
#   Progress(variant: :circular, value: 72, size: 64) { ProgressValue() }
#
# `variant: :bar` draws a track under the label and value; `:circular` an SVG ring with the
# value in its center. `indicator_color:` takes any CSS color, `thickness:` the weight in px.
# `value: nil` is indeterminate. To update it live, set `data-ui--progress-value-value` on the root.
class UI::Progress < UI::Base
  include UI::NumberFormat

  VARIANTS = %i[ bar circular ].freeze

  attr_reader :value, :label_id

  def initialize(value:, variant: :bar, min: 0, max: 100, size: 56, thickness: nil, indicator_color: nil, format: nil, locale: nil, **attributes)
    @variant = VARIANTS.include?(variant.to_sym) ? variant.to_sym : :bar
    @value, @min, @max = value, min, max
    @size = size
    @thickness = thickness || (@variant == :circular ? 4 : 6)
    @indicator_color = indicator_color || "var(--primary)"
    @format, @locale = format, locale
    @attributes = attributes
    @label_id = "progress-label-#{SecureRandom.hex(4)}"
  end

  def view_template(&)
    provide(:progress, self) do
      div(**mix(defaults(**root_attributes), @attributes.except(:class, :style)), style: "--progress-color: #{@indicator_color}; #{@attributes[:style]}".strip, class: cn(
        "grid w-full gap-x-2 gap-y-1.5",
        "data-[variant=bar]:grid-cols-[1fr_auto]",
        "data-[variant=bar]:**:data-[slot=progress-label]:col-start-1 data-[variant=bar]:**:data-[slot=progress-label]:row-start-1",
        "data-[variant=bar]:**:data-[slot=progress-value]:col-start-2 data-[variant=bar]:**:data-[slot=progress-value]:row-start-1 data-[variant=bar]:**:data-[slot=progress-value]:justify-self-end",
        "data-[variant=bar]:**:data-[slot=progress-track]:col-span-2",
        "data-[variant=circular]:w-fit data-[variant=circular]:justify-items-center",
        "data-[variant=circular]:**:data-[slot=progress-circular]:col-start-1 data-[variant=circular]:**:data-[slot=progress-circular]:row-start-1",
        "data-[variant=circular]:**:data-[slot=progress-value]:col-start-1 data-[variant=circular]:**:data-[slot=progress-value]:row-start-1 data-[variant=circular]:**:data-[slot=progress-value]:place-self-center",
        "data-[variant=circular]:**:data-[slot=progress-label]:row-start-2",
        override: @attributes[:class]
      )) do
        yield if block_given?
        @variant == :bar ? track : ring
      end
    end
  end

  def percentage
    return 0 if @value.nil?

    percent = (@value.to_f - @min) / (@max - @min) * 100
    percent.nan? ? 0 : percent.clamp(0, 100)
  end

  def formatted_value
    if @value.nil?
      ""
    elsif @format
      format_number(@value.clamp(@min, @max), @format)
    else
      format_number(percentage / 100, style: :percent)
    end
  end

  # Base UI's states, mirrored as data attributes on every part
  def state
    if @value.nil?
      :indeterminate
    elsif @value >= @max
      :complete
    else
      :progressing
    end
  end

  private
    def root_attributes
      {
        role: "progressbar", aria_valuemin: @min, aria_valuemax: @max,
        aria_valuenow: @value&.clamp(@min, @max), aria_valuetext: (formatted_value unless @value.nil?),
        aria_labelledby: (@label_id unless @attributes.key?(:aria_label)),
        data: {
          slot: "progress", variant: @variant, state => "", controller: "ui--progress",
          "ui--progress-value-value": @value, "ui--progress-min-value": @min, "ui--progress-max-value": @max,
          "ui--progress-format-value": (intl_options(@format).to_json if @format), "ui--progress-locale-value": @locale
        }
      }
    end

    def track
      div(data: { slot: "progress-track", state => "" }, style: "height: #{@thickness}px", class: "bg-background-strong relative w-full overflow-hidden rounded-full") do
        div(
          data: { slot: "progress-indicator", state => "", "ui--progress-target": "indicator" },
          style: ("inset-inline-start: 0; height: inherit; width: #{percentage.round(4)}%" unless @value.nil?),
          class: "rounded-full bg-(--progress-color) transition-[width] duration-300 motion-reduce:transition-none"
        )
      end
    end

    def ring
      center = @size / 2.0
      radius = (@size - @thickness) / 2.0
      circumference = 2 * Math::PI * radius

      svg(data: { slot: "progress-circular" }, width: @size, height: @size, viewBox: "0 0 #{@size} #{@size}", aria_hidden: "true", class: "overflow-visible") do |s|
        s.circle(data: { slot: "progress-track" }, cx: center, cy: center, r: radius, fill: "none", stroke_width: @thickness, class: "stroke-background-strong")
        s.circle(
          data: { slot: "progress-indicator", "ui--progress-target": "ring" }, cx: center, cy: center, r: radius, fill: "none",
          stroke_width: @thickness, stroke_linecap: "round", stroke_dasharray: circumference.round(4),
          stroke_dashoffset: (circumference - percentage / 100 * circumference).round(4), transform: "rotate(-90 #{center} #{center})",
          style: "stroke: var(--progress-color)", class: "transition-[stroke-dashoffset] duration-300 motion-reduce:transition-none"
        )
      end
    end
end
