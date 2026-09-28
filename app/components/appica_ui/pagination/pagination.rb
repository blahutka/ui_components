# Page links for a long list: a `<nav>` landmark around a row of links you lay out yourself -
# or let PaginationPages build the truncated range for you.
#
#   Pagination do
#     PaginationList do
#       PaginationItem { PaginationLink(href: "?page=1", active: true) { "1" } }
#       PaginationItem { PaginationLink(href: "?page=2") { "2" } }
#       PaginationItem { PaginationEllipsis() }
#     end
#   end
#
#   Pagination { PaginationPages(page: @page, pages: @pages) { |page| posts_path(page:) } }
#
# `variant:` (:outline, :soft) and `size:` flow to every link.
class AppicaUI::Pagination < AppicaUI::Base
  prop :variant,    one_of(%i[ outline soft ], :outline), default: -> { :outline }
  prop :size,       one_of(%i[ sm md lg ], :md), default: -> { :md }
  prop :aria_label, default: -> { t(".label") }

  attr_reader :variant, :size

  def view_template(&)
    provide(:ui_pagination, self) do
      nav(**mix({ aria_label: @aria_label, data: { slot: "pagination", variant: @variant, size: @size } }, @attributes.except(:class)),
        class: cn("data-disabled:opacity-disabled flex w-fit", override: @attributes[:class]), &)
    end
  end
end
