# A static measurement inside a known range - disk usage, a score, remaining battery.
# (For a task moving toward completion use Progress.)
#
#   Meter(value: 64) do
#     MeterLabel { "Storage" }
#     MeterValue()
#     MeterProgress()
#   end
#
# The root lays the parts out on a grid: label top-left, value top-right, track underneath.
# Pass `low:`, `high:` and/or `optimum:` and the fill turns green, amber or red by zone.
# To update it live, set `data-appica-ui--meter-value-value` on the root (see meter_controller.js).
class AppicaUI::Meter < AppicaUI::Base
  include AppicaUI::NumberFormat

  STATUS_CLASSES = {
    optimum: "bg-success-emphasis", suboptimum: "bg-warning-emphasis", invalid: "bg-error-emphasis", default: "bg-primary"
  }.freeze

  prop :value
  prop :min,            default: -> { 0 }
  prop :max,            default: -> { 100 }
  prop :low,            default: -> { nil }
  prop :high,           default: -> { nil }
  prop :optimum,        default: -> { nil }
  prop :format,         default: -> { nil }
  prop :locale,         default: -> { nil }
  prop :status_classes, ->(classes) { STATUS_CLASSES.merge(classes.to_h.transform_keys(&:to_sym)) }, default: -> { STATUS_CLASSES }

  attr_reader :value

  def label_id
    @label_id ||= "meter-label-#{SecureRandom.hex(4)}"
  end

  def view_template(&)
    provide(:meter, self) do
      div(**mix(defaults(**root_attributes), @attributes.except(:class)), class: cn(
        "grid w-full grid-cols-[1fr_auto] gap-x-2 gap-y-1.5",
        "**:data-[slot=meter-label]:col-start-1 **:data-[slot=meter-label]:row-start-1",
        "**:data-[slot=meter-value]:col-start-2 **:data-[slot=meter-value]:row-start-1 **:data-[slot=meter-value]:justify-self-end",
        "**:data-[slot=meter-progress]:col-span-2",
        override: @attributes[:class]
      ), &)
    end
  end

  def percentage
    percent = (@value.to_f - @min) / (@max - @min) * 100
    percent.nan? ? 0 : percent.clamp(0, 100)
  end

  def formatted_value
    if @format
      format_number(@value.clamp(@min, @max), @format)
    else
      format_number(percentage / 100, style: :percent)
    end
  end

  # Base UI's zones: below `low`, between, above `high`; the zone `optimum` sits in is green,
  # the next one amber and the far one red
  def status
    return if [ @low, @high, @optimum ].all?(&:nil?)

    low = @low || @min
    high = @high || @max
    zone = ->(number) { number < low ? 0 : (number > high ? 2 : 1) }
    distance = (zone.(@value) - zone.(@optimum || (@min + @max) / 2.0)).abs

    %i[ optimum suboptimum invalid ][distance]
  end

  def indicator_class
    @status_classes[status || :default]
  end

  private
    def root_attributes
      {
        role: "meter", aria_valuemin: @min, aria_valuemax: @max, aria_valuenow: @value.clamp(@min, @max), aria_valuetext: formatted_value,
        aria_labelledby: (label_id unless @attributes.key?(:aria_label)),
        data: {
          slot: "meter", status:, controller: "appica-ui--meter",
          "appica-ui--meter-value-value": @value, "appica-ui--meter-min-value": @min, "appica-ui--meter-max-value": @max,
          "appica-ui--meter-low-value": @low, "appica-ui--meter-high-value": @high, "appica-ui--meter-optimum-value": @optimum,
          "appica-ui--meter-format-value": (intl_options(@format).to_json if @format), "appica-ui--meter-locale-value": @locale,
          "appica-ui--meter-status-classes-value": @status_classes.to_json
        }
      }
    end
end
