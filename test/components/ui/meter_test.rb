require "test_helper"

class UI::MeterTest < ComponentTestCase
  test "renders a labelled meter with a percentage and a fill" do
    html = render_ui do
      Meter(value: 64) do
        MeterLabel { "Storage" }
        MeterValue()
        MeterProgress()
      end
    end
    meter = html.at_css("[data-slot=meter]")

    assert_equal "meter", meter["role"]
    assert_equal "64", meter["aria-valuenow"]
    assert_equal "64%", meter["aria-valuetext"]
    assert_equal html.at_css("[data-slot=meter-label]")["id"], meter["aria-labelledby"]
    assert_nil meter["data-status"]
    assert_equal "64%", html.at_css("[data-slot=meter-value]").text
    indicator = html.at_css("[data-slot=meter-indicator]")
    assert_includes indicator["style"], "width: 64.0%"
    assert_includes indicator["class"], "bg-primary"
  end

  test "thresholds pick the status zone" do
    { 32 => [ "optimum", "bg-success-emphasis" ], 64 => [ "suboptimum", "bg-warning-emphasis" ], 94 => [ "invalid", "bg-error-emphasis" ] }.each do |value, (status, color)|
      html = render_ui { Meter(value:, low: 40, high: 75, optimum: 10) { MeterProgress() } }

      assert_equal status, html.at_css("[data-slot=meter]")["data-status"]
      assert_includes html.at_css("[data-slot=meter-indicator]")["class"], color
    end
  end

  test "format and value blocks shape the text" do
    html = render_ui do
      Meter(value: 1280, max: 2000, format: { style: :currency, currency: "USD" }) { MeterValue() }
      Meter(value: 3.4, max: 8, format: { style: :unit, unit: "gigabyte", maximum_fraction_digits: 1 }) do
        MeterValue { |formatted, _value| "#{formatted} of 8 GB" }
      end
      Meter(value: 3, max: 4, aria_label: "Strength") { MeterValue(labels: %w[ a b c Good e ]) }
    end
    values = html.css("[data-slot=meter-value]").map(&:text)

    assert_equal [ "$1,280.00", "3.4 GB of 8 GB", "Good" ], values
    assert_equal "{\"style\":\"currency\",\"currency\":\"USD\"}", html.at_css("[data-slot=meter]")["data-ui--meter-format-value"]
    assert_nil html.css("[data-slot=meter]").last["aria-labelledby"]
  end

  test "parts outside a meter raise" do
    assert_raises(ArgumentError) { render_ui { MeterProgress() } }
  end
end
