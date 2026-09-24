# Server-side formatting of Meter / Progress values, following the Intl.NumberFormat options
# Appica takes (written in snake_case). The same options are handed to the Stimulus
# controllers, which format live updates with the browser's Intl.NumberFormat.
#
#   format_number(0.64, style: :percent)                                    # => "64%"
#   format_number(1280, style: :currency, currency: "USD")                  # => "$1,280.00"
#   format_number(3.4, style: :unit, unit: "gigabyte", maximum_fraction_digits: 1) # => "3.4 GB"
module UI::NumberFormat
  CURRENCIES = { "USD" => "$", "EUR" => "€", "GBP" => "£", "JPY" => "¥", "CZK" => "CZK " }.freeze
  UNITS = {
    "percent" => "%", "byte" => " byte", "kilobyte" => " kB", "megabyte" => " MB", "gigabyte" => " GB", "terabyte" => " TB",
    "second" => " sec", "minute" => " min", "hour" => " hr", "day" => " days", "meter" => " m", "kilometer" => " km"
  }.freeze

  private
    def format_number(value, format = {})
      options = format.to_h.transform_keys(&:to_sym)
      max = options[:maximum_fraction_digits]
      min = options[:minimum_fraction_digits]

      case options[:style]&.to_s
      when "percent"
        "#{rounded(value * 100, max || 0, min)}%"
      when "currency"
        code = options.fetch(:currency, "USD").to_s.upcase
        digits = max || (code == "JPY" ? 0 : 2)
        "#{CURRENCIES.fetch(code, "#{code} ")}#{rounded(value, digits, min || digits)}"
      when "unit"
        unit = options[:unit].to_s
        "#{rounded(value, max || 3, min)}#{UNITS.fetch(unit, " #{unit}")}"
      else
        rounded(value, max || 3, min)
      end
    end

    def rounded(value, max, min)
      ActiveSupport::NumberHelper.number_to_rounded(value, precision: max, delimiter: ",", strip_insignificant_zeros: min.nil? || min < max).then do |text|
        if min.to_i.positive? && !text.include?(".")
          "#{text}.#{"0" * min}"
        else
          text
        end
      end
    end

    # The options as Intl.NumberFormat expects them, for the browser
    def intl_options(format)
      format.to_h.to_h { |key, value| [ key.to_s.camelize(:lower), value.is_a?(Symbol) ? value.to_s : value ] }
    end
end
