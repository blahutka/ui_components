# Page links for a long list - laid out by hand, or built by PaginationPages.
#
# @label Pagination
# @logical_path Navigation
# @component UI::Pagination
# @display width wide
class UI::PaginationPreview < UI::BasePreview
  # @label Usage
  # PaginationPages renders the truncated range for `page:` of `pages:`; the block builds URLs.
  # @param page number
  # @param pages number
  # @param window number
  # @param edges [Boolean] toggle
  # @param variant [Symbol] select {{ choices_for UI::Pagination, :variant }}
  # @param size [Symbol] select {{ choices_for UI::Pagination, :size }}
  # @param aria_label text
  def default(page: 5, pages: 12, window: 1, edges: false, variant: :outline, size: :md, aria_label: nil)
    phlex do
      div(class: "max-w-full overflow-x-auto [scrollbar-width:none]") do
        Pagination(variant:, size:, **given(aria_label:)) { PaginationPages(page:, pages:, window: window.to_i, edges:) { |number| "?page=#{number}" } }
      end
    end
  end

  # @label Composed by hand
  # The parts on their own: an icon previous control (disabled on page 1), the current page,
  # an ellipsis for the gap and the last page.
  def manual
    phlex do
      Pagination do
        PaginationList do
          PaginationItem { PaginationLink(href: "#!", icon: true, disabled: true, aria_label: "Go to previous page") { Icon(:chevron_left) } }
          PaginationItem { PaginationLink(href: "#!", active: true) { "1" } }
          PaginationItem { PaginationLink(href: "#!") { "2" } }
          PaginationItem { PaginationLink(href: "#!") { "3" } }
          PaginationItem { PaginationEllipsis() }
          PaginationItem { PaginationLink(href: "#!") { "10" } }
          PaginationItem { PaginationLink(href: "#!", icon: true, aria_label: "Go to next page") { Icon(:chevron_right) } }
        end
      end
    end
  end

  # `:outline` draws bordered buttons; `:soft` fills on hover. The current page is filled in both.
  def variants
    phlex do
      div(class: "flex flex-col items-center gap-6") do
        %i[ outline soft ].each { |variant| Pagination(variant:) { PaginationPages(page: 1, pages: 4) { |number| "?page=#{number}" } } }
      end
    end
  end

  def sizes
    phlex do
      div(class: "flex flex-col items-center gap-6") do
        %i[ sm md lg ].each { |size| Pagination(size:) { PaginationPages(page: 2, pages: 3) { |number| "?page=#{number}" } } }
      end
    end
  end

  # @label With first & last
  def edges
    phlex do
      div(class: "max-w-full overflow-x-auto [scrollbar-width:none]") do
        Pagination { PaginationPages(page: 3, pages: 5, edges: true) { |number| "?page=#{number}" } }
      end
    end
  end

  # @label Buttons instead of links
  # A block with an argument puts a link's attributes on your own element - here buttons that
  # update the page in place.
  def controlled
    phlex do
      div(class: "flex flex-col items-center gap-3", data: { demo: "pages" }) do
        p(class: "text-foreground-muted text-sm", data: { demo: "status" }) { "Page 1 of 5" }
        Pagination do
          PaginationList do
            1.upto(5) do |number|
              PaginationItem do
                PaginationLink(active: number == 1, aria_label: "Go to page #{number}") { |link| button(**link, type: "button", data: { **link[:data], page: number }) { number.to_s } }
              end
            end
          end
        end
      end
      script(type: "module") do
        raw safe(<<~JS)
          const demo = document.querySelector("[data-demo=pages]")
          const current = #{UI::PaginationLink::CURRENT.to_json}.split(" ")
          demo.addEventListener("click", ({ target }) => {
            const chosen = target.closest("[data-page]")
            if (!chosen) return
            demo.querySelectorAll("[data-page]").forEach(link => {
              const active = link === chosen
              link.classList.toggle("text-primary-foreground", active)
              current.forEach(name => link.classList.toggle(name, active))
              active ? link.setAttribute("aria-current", "page") : link.removeAttribute("aria-current")
            })
            demo.querySelector("[data-demo=status]").textContent = `Page ${chosen.dataset.page} of 5`
          })
        JS
      end
    end
  end

  # @label RTL
  # The chevrons flip with the reading direction.
  def rtl
    phlex { div(dir: "rtl") { Pagination { PaginationPages(page: 4, pages: 9) { |number| "?page=#{number}" } } } }
  end
end
