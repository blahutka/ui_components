require "test_helper"

class AppicaUI::AvatarTest < ComponentTestCase
  test "renders the parts with the image hidden until loaded" do
    html = render_ui do
      Avatar do
        AvatarImage(src: "/avatars/01.png", alt: "Sarah Jenkins")
        AvatarFallback { "SJ" }
      end
    end

    root = html.at_css("[data-slot=avatar]")
    assert_equal "SPAN", root.name.upcase
    assert_equal "appica-ui--avatar", root["data-controller"]
    assert_equal "idle", root["data-status"]
    assert_includes root["class"], "text-[2.5rem]"
    assert_includes root["class"], "rounded-full"

    image = html.at_css("img[data-slot=avatar-image]")
    assert_equal "Sarah Jenkins", image["alt"]
    assert_includes image["class"].split, "hidden"
    assert_includes image["class"], "group-data-[status=loaded]/avatar:block"
    assert_equal "load->appica-ui--avatar#loaded error->appica-ui--avatar#failed", image["data-action"]

    fallback = html.at_css("[data-slot=avatar-fallback]")
    assert_equal "SJ", fallback.text
    assert_includes fallback["class"], "group-data-[status=loaded]/avatar:hidden"
  end

  test "preset and pixel sizes, and shapes" do
    html = render_ui do
      Avatar(size: :"2xl", shape: :rounded) { }
      Avatar(size: 44) { }
    end

    preset, pixel = html.css("[data-slot=avatar]")
    assert_includes preset["class"], "text-[5rem]"
    assert_includes preset["class"], "rounded-[calc(tan(atan2(var(--radius-md),2.5rem))*100%)]"
    assert_equal "font-size: 44px", pixel["style"]
    assert_no_match(/text-\[/, pixel["class"])
  end

  test "badge renders a dot, and a ping when animated" do
    html = render_ui do
      Avatar do
        AvatarBadge()
        AvatarBadge(animate: true, class: "text-foreground-subtle")
      end
    end

    plain, animated = html.css("[data-slot=avatar-badge]")
    assert_nil plain.at_css(".animate-ping-paced")
    assert animated.at_css(".animate-ping-paced")
    assert_includes animated["class"], "text-foreground-subtle"
    assert_not_includes animated["class"].split, "text-success-emphasis"
  end

  test "group passes size and shape down unless a child sets its own" do
    html = render_ui do
      AvatarGroup(size: :sm, shape: :rounded, orientation: :vertical) do
        Avatar { }
        Avatar(size: :xl) { }
      end
    end

    assert_includes html.at_css("[data-slot=avatar-group]")["class"], "flex-col"
    inherited, own = html.css("[data-slot=avatar]")
    assert_includes inherited["class"], "text-[2rem]"
    assert_includes inherited["class"], "rounded-[calc("
    assert_includes own["class"], "text-[4rem]"
  end

  test "fallback delay starts hidden" do
    fallback = render_ui { Avatar { AvatarFallback(delay: 600) { "SJ" } } }.at_css("[data-slot=avatar-fallback]")

    assert fallback.key?("hidden")
    assert_equal "600", fallback["data-delay"]
  end
end
