# Links between pages or sections, with the current one highlighted.
#
# @label Navigation
# @logical_path Navigation
# @component UI::Navigation
# @display width wide
class UI::NavigationPreview < UI::BasePreview
  ITEMS = { dashboard: "Dashboard", projects: "Projects", team: "Team", settings: "Settings" }.freeze
  ICONS = { dashboard: :layout_dashboard, projects: :folder, team: :users, settings: :settings }.freeze

  # @label Usage
  # @param variant [Symbol] select { choices: [pill, line] }
  # @param size [Symbol] select {{ choices_for UI::Navigation, :size }}
  # @param active_link [Symbol] select { choices: [dashboard, projects, team, settings] }
  # @param orientation [Symbol] select {{ choices_for UI::Navigation, :orientation }}
  def default(variant: :pill, size: :md, active_link: :dashboard, orientation: :horizontal)
    phlex do
      Navigation(variant:, size:, active_link:, orientation:, aria_label: "Main", class: "max-w-full") do
        NavigationList(class: "overflow-x-auto [scrollbar-width:none]") do
          ITEMS.each { |value, label| NavigationItem { NavigationLink(href: "#!", value:) { label } } }
        end
      end
    end
  end

  # `:pill` fills a rounded background; `:line` draws an underline in from the side.
  def variants
    phlex do
      div(class: "flex w-full flex-col items-center gap-8") do
        %i[ pill line ].each do |variant|
          Navigation(aria_label: variant.to_s.capitalize, variant:, active_link: "overview") do
            NavigationList do
              { overview: "Overview", analytics: "Analytics", reports: "Reports", notifications: "Notifications" }.each do |value, label|
                NavigationItem { NavigationLink(href: "#!", value:) { label } }
              end
            end
          end
        end
      end
    end
  end

  def sizes
    phlex do
      div(class: "flex flex-col gap-6") do
        %i[ sm md lg ].each do |size|
          Navigation(aria_label: size.to_s, size:, active_link: "home") do
            NavigationList { { home: "Home", docs: "Docs", pricing: "Pricing" }.each { |value, label| NavigationItem { NavigationLink(href: "#!", value:) { label } } } }
          end
        end
      end
    end
  end

  # @label With icons & badges
  # Mark a leading icon `data: { icon: "start" }` and a trailing Badge `data: { icon: "end" }`.
  def icons
    phlex do
      Navigation(aria_label: "Main", active_link: "dashboard", class: "max-w-full") do
        NavigationList(class: "overflow-x-auto [scrollbar-width:none]") do
          ITEMS.each do |value, label|
            NavigationItem do
              NavigationLink(href: "#!", value:) do
                Icon(ICONS[value], data: { icon: "start" })
                plain label
                Badge(variant: :outline, size: :sm, data: { icon: "end" }) { "4" } if value == :team
              end
            end
          end
        end
      end
    end
  end

  # @label Vertical sidebar
  def vertical
    phlex do
      div(class: "flex flex-wrap gap-10") do
        %i[ pill line ].each do |variant|
          Navigation(aria_label: "Sidebar #{variant}", orientation: :vertical, variant:, active_link: "projects", class: "w-48") do
            NavigationList do
              ITEMS.each { |value, label| NavigationItem { NavigationLink(href: "#!", value:, class: "w-full") { Icon(ICONS[value], data: { icon: "start" }); plain label } } }
            end
          end
        end
      end
    end
  end

  # @label Indicator variant
  # A chevron slides in on hover and on the current link - for documentation sidebars.
  def indicator
    phlex do
      Navigation(aria_label: "Docs", orientation: :vertical, variant: :indicator, active_link: "theming", class: "w-56") do
        NavigationList do
          { "getting-started": "Getting started", installation: "Installation", theming: "Theming", components: "Components" }.each do |value, label|
            NavigationItem { NavigationLink(href: "#!", value:) { label } }
          end
        end
      end
    end
  end

  # @label Controlled selection
  # A block with an argument puts the link's attributes on a <button>; a few lines of JS move
  # `aria-current` / `data-active` for in-page selection.
  def controlled
    phlex do
      Navigation(aria_label: "Settings", variant: :line, active_link: "account", data: { demo: "settings" }) do
        NavigationList do
          { account: "Account", security: "Security", billing: "Billing", team: "Team" }.each do |value, label|
            NavigationItem { NavigationLink(value:) { |link| button(**link, type: "button") { label } } }
          end
        end
      end
      script(type: "module") do
        raw safe(<<~JS)
          const nav = document.querySelector("[data-demo=settings]")
          nav.addEventListener("click", ({ target }) => {
            const chosen = target.closest("[data-slot=navigation-link]")
            if (!chosen) return
            nav.querySelectorAll("[data-slot=navigation-link]").forEach(link => {
              const current = link === chosen
              link.toggleAttribute("data-active", current)
              current ? link.setAttribute("aria-current", "page") : link.removeAttribute("aria-current")
            })
          })
        JS
      end
    end
  end

  # @label Disabled link
  # `active: true` marks the current link directly (e.g. `current_page?(path)`); `disabled:` dims one.
  def disabled
    phlex do
      Navigation(aria_label: "Main") do
        NavigationList do
          NavigationItem { NavigationLink(href: "#!", active: true) { "Overview" } }
          NavigationItem { NavigationLink(href: "#!") { "Changelog" } }
          NavigationItem { NavigationLink(href: "#!", disabled: true) { "Roadmap" } }
        end
      end
    end
  end

  # @label RTL
  # The line draws in and the indicator points with the reading direction.
  def rtl
    phlex do
      div(dir: "rtl", class: "flex flex-wrap items-start gap-10") do
        Navigation(aria_label: "رئيسي", variant: :line, active_link: "home") do
          NavigationList { { home: "الرئيسية", docs: "المستندات", pricing: "الأسعار" }.each { |value, label| NavigationItem { NavigationLink(href: "#!", value:) { label } } } }
        end
        Navigation(aria_label: "المستندات", orientation: :vertical, variant: :indicator, active_link: "theming", class: "w-48") do
          NavigationList { { start: "البدء", theming: "السمات", components: "المكونات" }.each { |value, label| NavigationItem { NavigationLink(href: "#!", value:) { label } } } }
        end
      end
    end
  end
end
