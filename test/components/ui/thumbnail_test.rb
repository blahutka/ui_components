require "test_helper"

class UI::ThumbnailTest < ComponentTestCase
  test "the image variant loads through Avatar's controller with a placeholder fallback" do
    thumbnail = render_ui { Thumbnail(src: "/summit.jpg", alt: "Mountain peak", size: :xl) }.at_css("[data-slot=thumbnail]")

    assert_equal "ui--avatar", thumbnail["data-controller"]
    assert_includes thumbnail["class"], "text-[4rem]"
    assert_includes thumbnail["class"], "bg-background-muted"
    image = thumbnail.at_css("img[data-slot=thumbnail-image]")
    assert_equal [ "/summit.jpg", "Mountain peak", "image" ], [ image["src"], image["alt"], image["data-ui--avatar-target"] ]
    assert thumbnail.at_css("[data-slot=thumbnail-fallback] svg[aria-hidden=true]")
  end

  test "without a source it shows only the fallback" do
    thumbnail = render_ui { Thumbnail() }.at_css("[data-slot=thumbnail]")

    assert_nil thumbnail.at_css("img")
    assert thumbnail.at_css("[data-slot=thumbnail-fallback]")
    assert_includes thumbnail["class"], "text-[2.5rem]"
  end

  test "icon variants frame their content and custom sizes set pixels" do
    thumbnail = render_ui { Thumbnail(variant: :icon_primary, size: 56, shape: :circle) { Icon(:bolt) } }.at_css("[data-slot=thumbnail]")

    assert_nil thumbnail["data-controller"]
    assert_equal "font-size: 56px", thumbnail["style"]
    assert_includes thumbnail["class"], "bg-primary"
    assert_includes thumbnail["class"], "rounded-full"
    assert thumbnail.at_css("svg")
    assert_nil thumbnail.at_css("[data-slot=thumbnail-fallback]")
  end
end
