require "test_helper"

class AppicaUI::SkeletonTest < ComponentTestCase
  test "a decorative block with the shimmer by default, shaped and tinted by class" do
    skeleton = render_ui { Skeleton(class: "text-primary size-10 rounded-full") }.at_css("div")

    assert_equal [ "skeleton", "shimmer", "true" ], [ skeleton["data-slot"], skeleton["data-effect"], skeleton["aria-hidden"] ]
    assert_includes skeleton["class"], "skeleton-shimmer"
    assert_includes skeleton["class"], "bg-current/10"
    assert_includes skeleton["class"], "text-primary"
    assert_includes skeleton["class"], "rounded-full"
    assert_not_includes skeleton["class"], "rounded-md"
    assert_not_includes skeleton["class"], "text-foreground-muted"
  end

  test "pulse and none effects" do
    pulse = render_ui { Skeleton(effect: :pulse) }.at_css("div")
    still = render_ui { Skeleton(effect: :none) }.at_css("div")

    assert_includes pulse["class"], "motion-safe:animate-pulse"
    assert_not_includes still["class"], "skeleton-shimmer"
    assert_not_includes still["class"], "animate-pulse"
  end
end
