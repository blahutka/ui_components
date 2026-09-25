require "test_helper"

class UI::TocTest < ComponentTestCase
  test "a labelled nav with a rail list of links indented by depth" do
    toc = render_ui do
      Toc(root_margin: "-64px 0px 0px 0px", container: "#article") do
        TocList do
          TocItem { TocLink(href: "#install") { "Install" } }
          TocItem { TocLink(href: "#gemfile", depth: 3) { "Gemfile" } }
          TocItem { TocLink(href: "#deep", depth: 9) { "Deep" } }
        end
      end
    end
    nav = toc.at_css("nav[data-slot=toc]")
    links = toc.css("a[data-slot=toc-link]")

    assert_equal [ "Table of contents", "ui--toc", "-64px 0px 0px 0px", "#article", "click->ui--toc#scroll" ],
      %w[ aria-label data-controller data-ui--toc-root-margin-value data-ui--toc-container-value data-action ].map { |attribute| nav[attribute] }
    assert_equal "list", toc.at_css("ul[data-slot=toc-list]")["role"]
    assert_includes toc.at_css("ul")["style"], "--toc-indicator-top: 0px"
    assert_equal [ "#install", "#gemfile", "#deep" ], links.map { |link| link["href"] }
    assert_equal [ "2", "3", "6" ], links.map { |link| link["data-depth"] }
    assert_includes links[1]["class"], "ps-7"
    assert_includes links[2]["class"], "ps-16"
    assert_equal "Obsah", I18n.with_locale(:cs) { render_ui { Toc() }.at_css("nav")["aria-label"] }
  end

  test "without a container clicks are left to the browser; a render prop gets the attributes" do
    toc = render_ui { Toc { TocLink(href: "#a") { |link| a(**link, class: "#{link[:class]} underline") { "A" } } } }

    assert_nil toc.at_css("nav")["data-action"]
    assert_equal [ "#a", "toc-link" ], toc.at_css("a").then { |link| [ link["href"], link["data-slot"] ] }
    assert_includes toc.at_css("a")["class"], "underline"
  end
end
