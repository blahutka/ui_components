require "test_helper"

class UI::CardTest < ComponentTestCase
  test "renders the frame, content wrapper and slots" do
    html = render_ui do
      Card do
        CardMedia(class: "h-40") { img(src: "/carousel/slide-1.jpg", alt: "") }
        CardHeader do
          CardTitle { "Weekly digest" }
          CardDescription { "What changed." }
        end
        CardFooter { Button { "Read" } }
      end
    end

    root = html.at_css("[data-slot=card]")
    assert_equal "DIV", root.name.upcase
    assert_equal "none", root["data-frame"]
    assert root.key?("data-inset")
    assert_includes root["class"], "[--card-radius:var(--radius-xl)]"

    content = root.at_css("> [data-slot=card-content]")
    assert_includes content["class"].split, "p-2"
    assert_includes content["class"].split, "border"

    assert_equal "H3", html.at_css("[data-slot=card-title]").name.upcase
    assert_equal "P", html.at_css("[data-slot=card-description]").name.upcase
    assert_includes html.at_css("[data-slot=card-media]")["class"], "group-data-inset/card:rounded-[calc(var(--card-radius)*3/4)]"
    assert html.at_css("[data-slot=card-footer] button")
  end

  test "frames" do
    html = render_ui do
      Card(frame: true) { }
      Card(frame: :glass) { }
    end

    solid, glass = html.css("[data-slot=card]")
    assert_equal "solid", solid["data-frame"]
    assert_includes solid["class"], "bg-background-subtle"
    assert_includes solid.at_css("[data-slot=card-content]")["class"], "border-border-muted"

    assert_equal "glass", glass["data-frame"]
    assert_includes glass["class"], "bg-white/10"
    assert_not_includes glass.at_css("[data-slot=card-content]")["class"].split, "border"
  end

  test "flush cards drop the inset" do
    root = render_ui { Card(inset: false) { } }.at_css("[data-slot=card]")

    assert_not root.key?("data-inset")
    assert_not_includes root.at_css("[data-slot=card-content]")["class"].split, "p-2"
  end

  test "as: and content: reach the root and the content wrapper" do
    html = render_ui do
      Card(as: :form, action: "/sign-in", content: { class: "md:flex-row", id: "inner" }) { CardTitle(as: :h2) { "Sign in" } }
    end

    form = html.at_css("form[data-slot=card]")
    assert_equal "/sign-in", form["action"]
    assert_equal "inner", form.at_css("[data-slot=card-content]")["id"]
    assert_includes form.at_css("[data-slot=card-content]")["class"], "md:flex-row"
    assert html.at_css("h2[data-slot=card-title]")
  end

  test "a caller radius replaces the default" do
    classes = render_ui { Card(class: "[--card-radius:var(--radius-3xl)]") { } }.at_css("[data-slot=card]")["class"]

    assert_includes classes, "[--card-radius:var(--radius-3xl)]"
    assert_not_includes classes, "[--card-radius:var(--radius-xl)]"
  end
end
