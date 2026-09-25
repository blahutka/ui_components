# A value (or a range) picked along a track. The number of thumbs follows the value: a number
# renders one, an array one per entry.
#
#   Slider(default_value: 50, thumb_aria_label: "Volume")
#   Slider(default_value: [ 25, 75 ], thumb_aria_label: [ "Minimum", "Maximum" ], name: "price")
#   Slider(default_value: 40, step: 10, tooltip: :always, format: { style: "percent" }, max: 1)
#
# Each thumb holds a visually hidden native <input type="range"> - it carries the name, the
# value, aria-valuenow and the focus, so the slider submits with forms. The `ui--slider`
# controller adds dragging anywhere on the track, the keyboard (arrows by `step`, Shift / Page
# Up·Down by `large_step`, Home / End) and keeps the fill, thumbs and tooltips in sync. It emits
# `ui--slider:change` while moving and `ui--slider:commit` on release, both with { value }.
class UI::Slider < UI::Base
  include UI::NumberFormat

  TOOLTIP_WRAPPER = "absolute z-10 pointer-events-none transition-transform duration-250 group-hover:scale-110 group-focus-within:scale-110 motion-reduce:transition-none " \
    "data-[orientation=horizontal]:bottom-full data-[orientation=horizontal]:left-1/2 data-[orientation=horizontal]:-translate-x-1/2 data-[orientation=horizontal]:mb-1 data-[orientation=horizontal]:origin-bottom " \
    "data-[orientation=vertical]:top-1/2 data-[orientation=vertical]:-translate-y-1/2 data-[orientation=vertical]:inset-s-full data-[orientation=vertical]:ms-1 data-[orientation=vertical]:ltr:origin-left data-[orientation=vertical]:rtl:origin-right"
  TOOLTIP = "bg-background-inverse text-foreground-inverse rounded-4xs block px-1 py-0.5 text-xs leading-none whitespace-nowrap " \
    "motion-safe:transition-[opacity,scale] motion-safe:duration-150 data-[orientation=horizontal]:origin-bottom data-[orientation=vertical]:ltr:origin-left data-[orientation=vertical]:rtl:origin-right"
  TOOLTIPS = {
    auto: "opacity-0 scale-90 group-hover:opacity-100 group-hover:scale-100 group-focus-within:opacity-100 group-focus-within:scale-100 group-data-dragging:opacity-100 group-data-dragging:scale-100",
    always: "opacity-100"
  }.freeze

  prop :value,            default: -> { nil }
  prop :default_value,    default: -> { nil }
  prop :min,              ->(value) { value.to_f }, default: -> { 0.0 }
  prop :max,              ->(value) { value.to_f }, default: -> { 100.0 }
  prop :step,             ->(value) { value.to_f }, default: -> { 1.0 }
  prop :large_step,       ->(value) { value.to_f }, default: -> { 10.0 }
  prop :min_steps_between_values, ->(value) { value.to_i }, default: -> { 0 }
  prop :orientation,      one_of(%i[ horizontal vertical ], :horizontal), default: -> { :horizontal }
  prop :tooltip,          one_of(%i[ auto always never ], :auto), default: -> { :auto }
  prop :thumb_aria_label, default: -> { nil }
  prop :format,           default: -> { nil }
  prop :disabled,         default: -> { false }
  prop :name,             default: -> { nil }

  def view_template
    div(**mix(defaults(
      role: "group",
      data: {
        slot: "slider", orientation: @orientation, disabled: ("" if disabled?), controller: "ui--slider",
        "ui--slider-min-value": number(@min), "ui--slider-max-value": number(@max), "ui--slider-step-value": number(@step),
        "ui--slider-large-step-value": number(@large_step), "ui--slider-min-steps-between-value": @min_steps_between_values,
        "ui--slider-format-value": (@format.to_h.transform_keys { |key| key.to_s.camelize(:lower) }.to_json if @format),
        "ui--slider-locale-value": I18n.locale.to_s
      }
    ), @attributes.except(:class)),
      class: cn("data-[orientation=horizontal]:w-full data-[orientation=vertical]:h-full data-[orientation=vertical]:w-fit", override: @attributes[:class])) do
      div(data: { slot: "slider-control", orientation: @orientation, disabled: ("" if disabled?), "ui--slider-target": "control", action: "pointerdown->ui--slider#start" },
        class: "relative flex w-full touch-none items-center select-none data-disabled:opacity-disabled data-disabled:pointer-events-none " \
          "data-[orientation=vertical]:h-full data-[orientation=vertical]:min-h-40 data-[orientation=vertical]:w-auto data-[orientation=vertical]:flex-col") do
        div(data: { slot: "slider-track", orientation: @orientation },
          class: "relative grow overflow-hidden rounded-full bg-background-strong select-none data-[orientation=horizontal]:h-1.5 data-[orientation=horizontal]:w-full data-[orientation=vertical]:h-full data-[orientation=vertical]:w-1.5") do
          div(data: { slot: "slider-indicator", orientation: @orientation, "ui--slider-target": "indicator" }, style: indicator_style,
            class: "bg-primary absolute select-none data-[orientation=horizontal]:inset-y-0 data-[orientation=vertical]:inset-x-0")
        end
        values.each_with_index { |value, index| thumb(value, index) }
      end
    end
  end

  private
    def values
      value = @value.nil? ? @default_value : @value
      value = @min if value.nil?
      @range = value.is_a?(Array)
      Array(value).map { |item| item.to_f.clamp(@min, @max) }
    end

    def percent(value)
      @max > @min ? ((value - @min) / (@max - @min) * 100).round(4) : 0
    end

    def indicator_style
      from, to = values.size > 1 ? [ percent(values.first), percent(values.last) ] : [ 0, percent(values.first) ]
      if @orientation == :vertical
        "bottom: #{from}%; height: #{to - from}%"
      else
        "inset-inline-start: #{from}%; width: #{to - from}%"
      end
    end

    def thumb(value, index)
      position = @orientation == :vertical ? "bottom: #{percent(value)}%; left: 50%" : "inset-inline-start: #{percent(value)}%; top: 50%"

      div(data: { slot: "slider-thumb", orientation: @orientation, index:, "ui--slider-target": "thumb" }, style: position,
        class: "group absolute block size-3 shrink-0 cursor-default rounded-full select-none " \
          "data-[orientation=horizontal]:-translate-y-1/2 data-[orientation=horizontal]:ltr:-translate-x-1/2 data-[orientation=horizontal]:rtl:translate-x-1/2 " \
          "data-[orientation=vertical]:-translate-x-1/2 data-[orientation=vertical]:translate-y-1/2") do
        span(data: { slot: "slider-thumb-visual" },
          class: "bg-background border-primary relative block size-full rounded-full border-2 shadow-xs transition-transform duration-250 group-hover:scale-125 group-focus-within:scale-125 group-data-dragging:scale-125 motion-reduce:transition-none")
        if @tooltip != :never
          span(data: { slot: "slider-tooltip-wrapper", orientation: @orientation }, class: TOOLTIP_WRAPPER) do
            span(data: { slot: "slider-tooltip", orientation: @orientation, "ui--slider-target": "tooltip" }, aria_hidden: "true", class: "#{TOOLTIP} #{TOOLTIPS[@tooltip]}") { formatted(value) }
          end
        end
        input(type: "range", id: (field&.control_id if index.zero?), name: input_name, value: number(value), min: number(@min), max: number(@max), step: number(@step),
          disabled: (true if disabled?), aria_label: thumb_label(index), aria_orientation: @orientation, aria_valuetext: (formatted(value) if @format),
          aria_labelledby: (field.label_id if field && !thumb_label(index)), aria_describedby: field&.described_by.presence,
          aria_invalid: ("true" if field&.invalid?),
          data: { "ui--slider-target": "input", "ui--field-target": ("control" if field), action: "keydown->ui--slider#key focus->ui--slider#focus" },
          class: "sr-only")
      end
    end

    def input_name
      name = @name || field&.name
      return unless name

      @range && !name.end_with?("[]") ? "#{name}[]" : name
    end

    # Inside a Field: the first thumb is the labelled control, the name comes from the Field
    def field
      context[:ui_field]
    end

    def disabled?
      @disabled || field&.disabled?
    end

    def thumb_label(index)
      case @thumb_aria_label
      when Array then @thumb_aria_label[index]
      when Proc then @thumb_aria_label.call(index)
      else @thumb_aria_label
      end
    end

    def formatted(value)
      @format ? format_number(value, @format) : number(value)
    end

    # 50.0 → "50", 0.25 → "0.25"
    def number(value)
      value.to_f.then { |float| float == float.to_i ? float.to_i.to_s : float.to_s }
    end
end
