require "test_helper"

class UI::LoaderTest < ComponentTestCase
  test "renders the bar with a soft track and two clipped sweeps" do
    loader = render_ui { Loader() }.at_css("[data-slot=loader]")
    clip_id = loader.at_css("clipPath")["id"]

    assert_equal "status", loader["role"]
    assert_equal "bar", loader["data-variant"]
    assert_includes loader.at_css("svg > rect")["class"], "text-primary-soft"
    assert_equal "url(##{clip_id})", loader.at_css("g")["clip-path"]
    assert_equal 2, loader.css("g > rect").size
    assert_equal "1.15s", loader.css("g > rect").last.at_css("animate")["begin"]
  end

  test "dots flow three circles and current_color uses the text color" do
    loader = render_ui { Loader(variant: :dots, current_color: true) }.at_css("[data-slot=loader]")

    assert_equal "dots", loader["data-variant"]
    assert_equal 3, loader.css("g.motion-reduce\\:hidden circle").size
    assert_includes loader.at_css("svg")["class"], "text-current"
  end
end
