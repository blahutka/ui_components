require "test_helper"

class AppicaUI::Blocks::ReviewSummaryTest < ComponentTestCase
  COUNTS = { 5 => 1_002, 4 => 180, 3 => 64, 2 => 26, 1 => 12 }.freeze

  test "renders the score, stars, count, breakdown and highlight" do
    html = render_ui do
      ReviewSummary(rating: 4.8, reviews: 1_284) do
        ReviewBreakdown(counts: COUNTS)
        ReviewHighlight(avatars: [ { src: "/avatars/02.png", alt: "Liam Hudson" } ]) { "Loved by 12,000+ shoppers" }
      end
    end

    assert_equal "4.8", html.at_css("[data-slot=review-score]").text
    assert_equal "4.8 out of 5", html.at_css("[data-slot=rating]")["aria-label"]
    assert_includes html.at_css("[data-slot=rating]")["class"], "text-warning-emphasis"
    assert_includes html.text, "1,284 verified reviews"

    rows = html.css("[data-slot=review-breakdown-row]")
    assert_equal %w[ 5 4 3 2 1 ], rows.map { |row| row["data-stars"] }
    assert_equal [ "78%", "14%", "5%", "2%", "1%" ], rows.map { |row| row.css("span").last.text }
    assert_equal "5 star reviews", rows.first.at_css("[role=meter]")["aria-label"]
    assert_includes rows.first.at_css("[data-slot=meter-indicator]")["style"], "width: 78.0%"

    assert html.at_css("[data-slot=separator]")
    assert_equal "/avatars/02.png", html.at_css("[data-slot=avatar-group] img")["src"]
    assert_includes html.at_css("[data-slot=review-highlight]").text, "Loved by 12,000+ shoppers"
  end

  test "counts pluralize and numbers follow the locale" do
    html = I18n.with_locale(:cs) { render_ui { ReviewSummary(rating: 4.8, reviews: 1_284) { ReviewBreakdown(counts: COUNTS) } } }

    assert_equal "4,8", html.at_css("[data-slot=review-score]").text
    assert_includes html.text, "1.284 ověřených recenzí"
    assert_equal "4 ověřené recenze", I18n.with_locale(:cs) { render_ui { ReviewSummary(rating: 4, reviews: 4) }.at_css("[data-slot=review-summary] .mt-1").text }
    assert_equal "1 review", render_ui { ReviewSummary(rating: 5, reviews: 1, verified: false) }.at_css(".mt-1").text
  end

  test "href links each row; empty counts render zero rows" do
    html = render_ui { ReviewSummary(rating: 0) { ReviewBreakdown(counts: {}, href: ->(stars) { "/reviews?stars=#{stars}" }) } }

    assert_equal "/reviews?stars=5", html.at_css("a[data-slot=review-breakdown-row]")["href"]
    assert_equal [ "0%" ] * 5, html.css("[data-slot=review-breakdown-row]").map { |row| row.css("span").last.text }
    assert_nil html.at_css(".mt-1")
  end

  test "parts outside a ReviewSummary raise" do
    assert_raises(ArgumentError) { render_ui { ReviewBreakdown(counts: COUNTS) } }
  end
end
