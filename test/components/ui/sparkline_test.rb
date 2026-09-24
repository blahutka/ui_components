require "test_helper"

class UI::SparklineTest < ComponentTestCase
  DATA = [ 4, 8, 6, 10, 7, 12 ].freeze
  LABELS = %w[Mon Tue Wed Thu Fri Sat].freeze

  test "renders a line chart and exposes its data to the controller" do
    html = render_ui do
      Sparkline(data: DATA, labels: LABELS, color: "var(--success-emphasis)") do
        SparklineChart(aria_label: "Weekly signups")
      end
    end

    root = html.at_css("[data-slot=sparkline]")
    assert_equal "ui--sparkline", root["data-controller"]
    assert_equal DATA.to_json, root["data-ui--sparkline-data-value"]
    assert_equal LABELS.to_json, root["data-ui--sparkline-labels-value"]
    assert_includes root["style"], "--sparkline-color: var(--success-emphasis)"

    chart = html.at_css("[data-slot=sparkline-chart]")
    assert_equal "img", chart["role"]
    assert_equal "Weekly signups", chart["aria-label"]
    assert_equal "line", chart["data-variant"]
    assert_equal "48px", chart["style"][/height:\s*([^;]+)/, 1]
    assert html.at_css("svg[data-slot=sparkline-svg]")
    path = html.at_css("path[data-slot=sparkline-line]")["d"]
    assert path.start_with?("M ")
    assert_match(/20(?:\.0)? 24(?:\.0)?/, path)
    assert_equal "butt", html.at_css("path[data-slot=sparkline-line]")["stroke-linecap"],
                 "the open path should start cleanly without a stretched round cap"
    assert_nil html.at_css("[data-slot=sparkline-fill]")
  end

  test "area and filled line render their distinct fills" do
    html = render_ui do
      Sparkline(data: [ 3, -4, 2, 6 ], id: "area") do
        SparklineChart(variant: :area, baseline: 0)
      end
      Sparkline(data: DATA, id: "filled") do
        SparklineChart(fill: true)
      end
    end

    area = html.at_css("#area")
    assert_equal "var(--sparkline-color)", area.at_css("[data-slot=sparkline-fill]")["fill"]
    assert_equal "0.18", area.at_css("[data-slot=sparkline-fill]")["fill-opacity"]
    assert area.at_css("line[data-slot=sparkline-baseline]")

    filled = html.at_css("#filled")
    assert_match(/url\(#sparkline-gradient-/, filled.at_css("[data-slot=sparkline-fill]")["fill"])
    assert_nil filled.at_css("line[data-slot=sparkline-baseline]")
  end

  test "default preview applies the selected color" do
    preview = UI::SparklinePreview.new.default(color: :error).fetch(:component)
    html = Nokogiri::HTML5.fragment(preview.call)
  rescue ArgumentError => error
    flunk "default preview must accept a color option: #{error.message}"
  else
    assert_includes html.at_css("[data-slot=sparkline]")["style"],
                    "--sparkline-color: var(--error-emphasis)"
  end

  test "colors preview renders every configured chart" do
    preview = UI::SparklinePreview.new.colors.fetch(:component)
    html = Nokogiri::HTML5.fragment(preview.call)
  rescue NoMethodError => error
    flunk "colors preview must render: #{error.message}"
  else

    sparklines = html.css("[data-slot=sparkline]")
    charts = html.css("[data-slot=sparkline-chart]")

    assert_equal 5, sparklines.size
    assert_equal %w[area area line line column], charts.map { |chart| chart["data-variant"] }
    assert_equal [
      "var(--success-emphasis)",
      "var(--error-emphasis)",
      "var(--warning-emphasis)",
      "#a855f7",
      "var(--info-emphasis)"
    ], sparklines.map { |sparkline| sparkline["style"][/--sparkline-color:\s*([^;]+)/, 1] }
    assert charts[3].at_css("[data-slot=sparkline-fill]")
  end

  test "column chart renders one signed bar per value and a baseline" do
    html = render_ui do
      Sparkline(data: [ 6, -4 ]) { SparklineChart(variant: :column, baseline: 0) }
    end

    bars = html.css("[data-slot=sparkline-column]")
    assert_equal 2, bars.size
    assert_includes bars.first["class"], "rounded-t-"
    assert_includes bars.last["class"], "rounded-b-"
    assert_includes bars.first["style"], "height: 60.0%"
    assert_includes bars.last["style"], "height: 40.0%"
    assert_includes html.at_css("[data-slot=sparkline-baseline]")["style"], "60.0%"
  end

  test "value and label show the last point and are controller targets" do
    html = render_ui do
      Sparkline(data: DATA, labels: LABELS) do
        SparklineLabel()
        SparklineValue()
      end
    end

    value = html.at_css("[data-slot=sparkline-value]")
    assert_equal "12", value.text
    assert_equal "value", value["data-ui--sparkline-target"]

    label = html.at_css("[data-slot=sparkline-label]")
    assert_equal "Sat", label.text
    assert_equal "label", label["data-ui--sparkline-target"]
  end

  test "label renders nothing when labels are absent" do
    html = render_ui { Sparkline(data: DATA) { SparklineLabel() } }

    assert_nil html.at_css("[data-slot=sparkline-label]")
  end

  test "interactive chart includes pointer actions, indicator, and tooltip" do
    html = render_ui do
      Sparkline(data: DATA, labels: LABELS) do
        SparklineChart(tooltip: true)
      end
    end

    chart = html.at_css("[data-slot=sparkline-chart]")
    assert_includes chart["data-action"], "pointermove->ui--sparkline#activate"
    assert_includes chart["data-action"], "pointerleave->ui--sparkline#clear"
    assert_includes chart["style"], "touch-action: pan-y"
    assert chart.at_css("[data-ui--sparkline-target=guide]").key?("hidden")
    assert chart.at_css("[data-ui--sparkline-target=dot]").key?("hidden")
    assert chart.at_css("[data-slot=sparkline-tooltip]").key?("hidden")
  end

  test "empty data omits the chart visualization" do
    html = render_ui do
      Sparkline(data: []) do
        SparklineChart()
        SparklineValue()
      end
    end

    assert_nil html.at_css("[data-slot=sparkline-chart]")
    assert_equal "", html.at_css("[data-slot=sparkline-value]").text
  end

  test "parts outside the root raise a helpful error" do
    error = assert_raises(ArgumentError) { render_ui { SparklineChart() } }
    assert_match "must be rendered inside Sparkline", error.message
  end
end
