require "test_helper"

class AppicaUI::RatingTest < ComponentTestCase
  test "renders a radiogroup of items filled up to the value" do
    rating = render_ui { Rating(default_value: 3.5, step: 0.5, name: "score") }.at_css("[data-slot=rating]")
    items = rating.css("button[data-slot=rating-item]")

    assert_equal "radiogroup", rating["role"]
    assert_equal "Rating", rating["aria-label"]
    assert_equal "appica-ui--rating", rating["data-controller"]
    assert_includes rating["style"], "--rating-size: 24px"
    assert_equal 5, items.size
    assert_equal [ "100%", "100%", "100%", "50.0%", "0%" ], items.map { |item| item["style"][/[\d.]+%/] }
    assert_equal [ "false", "false", "false", "true", "false" ], items.map { |item| item["aria-checked"] }
    assert_equal "0", items[3]["tabindex"]
    assert_equal "4 of 5", items[3]["aria-label"]
    assert_equal "3.5", rating.at_css("input[type=hidden][name=score]")["value"]
  end

  test "an unrated group focuses the first item" do
    items = render_ui { Rating() }.css("button[data-slot=rating-item]")

    assert_equal [ "0", "-1", "-1", "-1", "-1" ], items.map { |item| item["tabindex"] }
  end

  test "read_only is a labelled image without buttons" do
    rating = render_ui { Rating(value: 4.3, step: 0.1, size: 14, read_only: true) }.at_css("[data-slot=rating]")

    assert_equal "img", rating["role"]
    assert_equal "4.3 out of 5", rating["aria-label"]
    assert_nil rating["data-controller"]
    assert_empty rating.css("button")
    assert_includes rating.css("[data-slot=rating-item]").last["style"], "30.0%"
    assert_equal "4,3 z 5", I18n.with_locale(:cs) { render_ui { Rating(value: 4.3, read_only: true) }.at_css("[role=img]")["aria-label"] }
  end

  test "variants and icons pick the base and fill glyphs" do
    filled = render_ui { Rating(icon: :heart) }.at_css("[data-slot=rating-item]")
    outline = render_ui { Rating(variant: :outline, icon: { empty: :thumb_up, filled: :thumb_up_filled }) }.at_css("[data-slot=rating-item]")

    assert_equal "heart-filled", filled.at_css("[data-slot=rating-item-base] svg")["data-name"]
    assert_includes filled.at_css("[data-slot=rating-item-base]")["class"], "text-border-strong"
    assert_equal "heart-filled", filled.at_css("[data-slot=rating-item-fill] svg")["data-name"]
    assert_equal "thumb-up", outline.at_css("[data-slot=rating-item-base] svg")["data-name"]
    assert_equal "thumb-up-filled", outline.at_css("[data-slot=rating-item-fill] svg")["data-name"]
  end

  test "an own label, vertical orientation, disabled" do
    rating = render_ui { Rating(aria_labelledby: "label", orientation: :vertical, disabled: true, size: "1em") }.at_css("[data-slot=rating]")

    assert_nil rating["aria-label"]
    assert_equal "vertical", rating["aria-orientation"]
    assert rating.key?("data-disabled")
    assert rating.css("button").all? { |button| button.key?("disabled") }
    assert_includes rating["style"], "--rating-size: 1em"
  end
end
