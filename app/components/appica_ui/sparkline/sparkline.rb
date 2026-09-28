# Root of the sparkline compound component. Owns the series, labels and number
# formatting; the Stimulus controller keeps every part on the same active point.
#
#   Sparkline(data: values, labels: dates) do
#     SparklineValue()
#     SparklineChart(fill: true, tooltip: true, aria_label: "Weekly revenue")
#   end
class AppicaUI::Sparkline < AppicaUI::Base
  prop :data,   ->(values) { Array(values).map { |value| value.is_a?(Numeric) ? value : Float(value) } }
  prop :labels, ->(labels) { labels&.map(&:to_s) }, default: -> { nil }
  prop :color,  default: -> { "var(--primary)" }
  prop :format, ->(format) { (format || {}).to_h.symbolize_keys }, default: -> { {} }
  prop :locale, default: -> { nil }

  attr_reader :data, :labels

  def formatted_values
    @formatted_values ||= data.map { |value| format_number(value) }
  end

  def view_template(&)
    provide(:ui_sparkline, self) do
      div(**mix(root_attributes, @attributes.except(:class, :style)),
          class: cn("flex flex-col gap-1.5", override: @attributes[:class]),
          style: root_style, &)
    end
  end

  def point(index)
    { index:, value: data[index], label: labels&.[](index) }
  end

  private
    def root_attributes
      {
        data: {
          slot: "sparkline",
          controller: "appica-ui--sparkline",
          "appica-ui--sparkline-data-value": data.to_json,
          "appica-ui--sparkline-labels-value": labels&.to_json,
          "appica-ui--sparkline-formatted-values-value": formatted_values.to_json
        }
      }
    end

    def root_style
      [ "--sparkline-color: #{@color}", @attributes[:style] ].compact.join("; ")
    end

    def format_number(value)
      return "" unless value.finite?

      precision = @format[:maximum_fraction_digits]
      common = { precision:, strip_insignificant_zeros: true }.compact

      case @format[:style]&.to_sym
      when :currency
        ActiveSupport::NumberHelper.number_to_currency(value, **common, unit: currency_unit(@format[:currency]), locale: supported_locale)
      when :percent
        ActiveSupport::NumberHelper.number_to_percentage(value * 100, **common, locale: supported_locale)
      else
        if precision
          ActiveSupport::NumberHelper.number_to_rounded(value, **common, locale: supported_locale)
        else
          ActiveSupport::NumberHelper.number_to_delimited(value, locale: supported_locale)
        end
      end
    end

    def currency_unit(currency)
      { "USD" => "$", "EUR" => "€", "GBP" => "£", "JPY" => "¥" }.fetch(currency.to_s.upcase, "#{currency} ")
    end

    def supported_locale
      @locale if @locale && I18n.available_locales.map(&:to_s).include?(@locale.to_s)
    end
end
