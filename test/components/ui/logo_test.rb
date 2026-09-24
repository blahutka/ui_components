require "test_helper"

class UI::LogoTest < ComponentTestCase
  test "renders the SVG mark and a three-part wordmark" do
    html = render_ui { Logo() }

    root = html.at_css("span[data-slot=logo]")
    assert_includes root["class"], "text-2xl"
    assert_includes root["class"], "[--logo-accent:#4a8fd6]"

    mark = root.at_css("svg[data-slot=logo-mark]")
    assert_equal "true", mark["aria-hidden"]
    clip_id = mark.at_css("clipPath")["id"]
    assert_equal "url(##{clip_id})", mark.at_css("g")["clip-path"]

    parts = root.css("[data-slot=logo-wordmark] > span")
    assert_equal [ "Be", "humble", ".com" ], parts.map(&:text)
    assert_includes parts[0]["class"], "font-bold"
    assert_includes parts[1]["class"], "font-light"
    assert_includes parts[2]["class"], "text-(--logo-accent)"
  end

  test "text, size and accent are configurable" do
    root = render_ui { Logo(prefix: "", name: "Sproutly", suffix: ".app", size: :xl, accent: :violet) }.at_css("[data-slot=logo]")

    assert_equal [ "Sproutly", ".app" ], root.css("[data-slot=logo-wordmark] > span").map(&:text)
    assert_includes root["class"], "text-6xl"
    assert_includes root["class"], "[--logo-accent:#7c5cff]"
  end

  test "the mark alone is an image named after the brand" do
    root = render_ui { Logo(variant: :mark) }.at_css("[data-slot=logo]")

    assert_equal "img", root["role"]
    assert_equal "Behumble.com", root["aria-label"]
    assert_nil root.at_css("[data-slot=logo-wordmark]")
  end

  test "wordmark variant drops the mark; href renders a link" do
    html = render_ui do
      Logo(variant: :wordmark)
      Logo(href: "/", aria_label: "Home")
    end

    assert_nil html.css("[data-slot=logo]").first.at_css("svg")
    link = html.at_css("a[data-slot=logo]")
    assert_equal "/", link["href"]
    assert_equal "Home", link["aria-label"]
  end

  test "each mark gets its own clip path id" do
    html = render_ui { 2.times { Logo(variant: :mark) } }

    ids = html.css("clipPath").map { |clip| clip["id"] }
    assert_equal 2, ids.uniq.size
  end
end
