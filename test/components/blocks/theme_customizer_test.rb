require "test_helper"

class Blocks::ThemeCustomizerTest < ComponentTestCase
  test "renders the mode, color, font and radius settings, the CSS dialog and the reset" do
    html = render_ui { ThemeCustomizer(id: "theme") }

    root = html.at_css("[data-slot=theme-customizer]")
    assert_equal "blocks--theme-customizer", root["data-controller"]
    assert_equal "Settings", root.at_css("h2").text
    assert_equal %w[ light dark system ], root.css("[data-slot=toggle-group] [data-slot=toggle]").map { |toggle| toggle["value"] }

    selects = root.css("[data-blocks--theme-customizer-setting]")
    assert_equal %w[ base primary secondary font radius ], selects.map { |select| select["data-blocks--theme-customizer-setting"] }
    values = ->(setting) { root.css("[data-blocks--theme-customizer-setting=#{setting}] [role=option]").map { |option| option["data-value"] } }
    assert_equal %w[ slate gray zinc neutral stone taupe mauve mist olive ], values.call("base")
    assert_equal %w[ custom base red ], values.call("primary").first(3)
    assert_equal "custom", values.call("secondary").first
    assert_equal %w[ none xsmall small medium large xlarge ], values.call("radius")
    assert_includes values.call("font"), "geist"

    assert_equal 2, root.css("[data-blocks--theme-customizer-target=custom][hidden] input[type=color]").size
    assert_equal "Get CSS Code", root.at_css("button[aria-haspopup=dialog]").text.strip
    assert root.at_css("pre#theme-css[data-blocks--theme-customizer-target=css]")
    assert_equal "#theme-css", root.at_css("[data-slot=copy-button]")["data-ui--copy-button-target-value"]
    assert root.at_css("input[type=checkbox][role=switch][data-blocks--theme-customizer-target=animations]")
    assert_includes root.css("button").map { |button| button.text.strip }, "Reset to defaults"
  end
end
