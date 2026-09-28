require "test_helper"

class AppicaUI::PaginationTest < ComponentTestCase
  test "PaginationPages builds a truncated range with previous and next" do
    nav = render_ui { Pagination { PaginationPages(page: 5, pages: 12) { |page| "/posts?page=#{page}" } } }
    items = nav.css("li[data-slot=pagination-item]").map { |item| item.at_css("[data-slot=pagination-ellipsis]") ? "…" : item.text.strip }
    current = nav.at_css("[aria-current=page]")

    assert_equal "Pagination", nav.at_css("nav[data-slot=pagination]")["aria-label"]
    assert_equal [ "", "1", "…", "4", "5", "6", "…", "12", "" ], items
    assert_equal [ "5", "/posts?page=5", "Go to page 5" ], [ current.text, current["href"], current["aria-label"] ]
    assert_equal "/posts?page=4", nav.at_css("a[aria-label='Go to previous page']")["href"]
    assert_equal "/posts?page=6", nav.at_css("a[aria-label='Go to next page']")["href"]
  end

  test "a gap of one page shows the page; the ends disable prev / next; edges add first / last" do
    first = render_ui { Pagination { PaginationPages(page: 1, pages: 4, edges: true) { |page| "?p=#{page}" } } }
    labels = first.css("[data-slot=pagination-link]").map { |link| link["aria-label"] }

    assert_equal [ "1", "2", "3", "4" ], first.css("a[aria-label^='Go to page']").map(&:text)
    assert_equal "Go to first page", labels.first
    assert_equal "Go to last page", labels.last
    previous = first.at_css("[aria-label='Go to previous page']")
    assert_equal [ "true", "-1", nil ], [ previous["aria-disabled"], previous["tabindex"], previous["href"] ]
    assert_equal "Přejít na další stránku", I18n.with_locale(:cs) { render_ui { Pagination { PaginationPages(page: 1, pages: 2) { "#" } } }.css("[data-slot=pagination-link]").last["aria-label"] }
  end

  test "variant and size flow to the links; the current page is filled" do
    nav = render_ui { Pagination(variant: :soft, size: :lg) { PaginationLink(href: "#", active: true) { "1" }; PaginationEllipsis() } }
    link = nav.at_css("a")

    assert_equal [ "soft", "lg", "true" ], [ link["data-variant"], link["data-size"], link["data-active"] ]
    assert_includes link["class"], "h-12"
    assert_includes link["class"], "before:bg-primary"
    assert_includes nav.at_css("[data-slot=pagination-ellipsis]")["class"], "h-12"
    assert_equal "More pages", nav.at_css("[data-slot=pagination-ellipsis] .sr-only").text
  end
end
