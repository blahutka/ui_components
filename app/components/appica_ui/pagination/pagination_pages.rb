# The whole row for page `page:` of `pages:` - previous, the first and last pages, a `window:`
# of pages around the current one with ellipses for the gaps, and next. The block turns a page
# number into its URL. `edges: true` adds first / last jumps.
#
#   Pagination { PaginationPages(page: @page, pages: @pages) { |page| posts_path(page:) } }
class AppicaUI::PaginationPages < AppicaUI::Base
  prop :page,   ->(value) { value.to_i }
  prop :pages,  ->(value) { value.to_i }
  prop :window, default: -> { 1 }
  prop :edges,  default: -> { false }

  # The block builds URLs; Phlex would render its return value as content, so keep the raw block
  def before_template(&url)
    @url = url
    super
  end

  def view_template
    render AppicaUI::PaginationList.new(**@attributes) do
      jump(:first, 1, :chevrons_left) if @edges
      jump(:previous, @page - 1, :chevron_left)
      series.each do |page|
        render AppicaUI::PaginationItem.new do
          if page == :gap
            render AppicaUI::PaginationEllipsis.new
          else
            render(AppicaUI::PaginationLink.new(href: @url.call(page), active: page == @page, aria_label: t(".page", page:))) { page.to_s }
          end
        end
      end
      jump(:next, @page + 1, :chevron_right)
      jump(:last, @pages, :chevrons_right) if @edges
    end
  end

  private
    # 1 … 4 5 6 … 20 (a gap of a single page shows that page instead)
    def series
      shown = ([ 1, @pages ] + ((@page - @window)..(@page + @window)).to_a).select { |page| page.between?(1, @pages) }.uniq.sort
      shown.each_with_object([]) do |page, pages|
        previous = pages.reverse.find { |item| item != :gap }
        if previous && page - previous == 2
          pages << page - 1
        elsif previous && page - previous > 2
          pages << :gap
        end
        pages << page
      end
    end

    def jump(direction, page, icon)
      out_of_range = !page.between?(1, @pages) || page == @page
      render AppicaUI::PaginationItem.new do
        render(AppicaUI::PaginationLink.new(href: (@url.call(page) unless out_of_range), disabled: out_of_range, icon: true, aria_label: t(".#{direction}"))) do
          render AppicaUI::Icon.new(icon, class: "rtl:rotate-180")
        end
      end
    end
end
