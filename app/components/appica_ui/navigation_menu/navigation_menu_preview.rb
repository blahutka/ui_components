# Site navigation whose items open rich panels of links.
#
# @label Navigation Menu
# @logical_path Navigation
# @component AppicaUI::NavigationMenu
# @display width wide
# @display min_height 360px
class AppicaUI::NavigationMenuPreview < AppicaUI::BasePreview
  # Props not in the Usage form (data, render blocks, generated ids): see ui_components:preview_params
  UNLISTED_PROPS = %i[ side_offset id ].freeze

  PRODUCTS = [
    [ "Analytics", "Track usage and conversions in real time.", :device_desktop_analytics ],
    [ "Components", "A composable library of UI primitives.", :cube ],
    [ "Automation", "Wire up workflows without code.", :bolt ],
    [ "Integrations", "Connect the tools your team already uses.", :code ]
  ].freeze
  RESOURCES = [ [ "Documentation", "Guides and API references.", :book ], [ "Support", "Reach our team for help.", :lifebuoy ] ].freeze
  CARD = "h-auto flex-col items-start gap-1 whitespace-normal"

  # A card link with an icon, a title and a description
  CARDS = proc do |cards|
    cards.each do |title, description, icon|
      li do
        NavigationMenuLink(href: "#!", class: CARD) do
          span(class: "text-foreground-intense flex items-center gap-1.5 font-medium") { Icon(icon) if icon; plain title }
          span(class: "text-foreground-muted text-xs font-normal") { description }
        end
      end
    end
  end

  SIMPLE = proc do |links = %w[ Overview Changelog Roadmap Releases ]|
    NavigationMenuItem do
      NavigationMenuTrigger { plain "Product"; NavigationMenuIcon() }
      NavigationMenuContent { ul(class: "grid w-50 gap-0.5") { links.each { |label| li { NavigationMenuLink(href: "#!") { label } } } } }
    end
    NavigationMenuItem { NavigationMenuLink(href: "#!") { "Pricing" } }
  end

  # @label Usage
  # Two panel items and a plain link; the popup morphs between the panels. Hover, click or ↓.
  # @param variant [Symbol] select {{ choices_for AppicaUI::NavigationMenu, :variant }}
  # @param size [Symbol] select {{ choices_for AppicaUI::NavigationMenu, :size }}
  # @param icon [Symbol] select { choices: [chevron, caret, plus] }
  # @param orientation [Symbol] select {{ choices_for AppicaUI::NavigationMenu, :orientation }}
  # @param morph [Boolean] toggle
  # @param backdrop [Boolean] toggle
  # @param viewport [Boolean] toggle
  # @param default_value text
  # @param delay number
  # @param close_delay number
  def default(variant: :pill, size: :md, icon: :chevron, orientation: :horizontal, morph: true, backdrop: false, viewport: true, default_value: nil, delay: 50, close_delay: 50)
    phlex do
      NavigationMenu(variant:, size:, icon:, orientation:, morph:, backdrop:, viewport:, delay:, close_delay:, **given(default_value:), aria_label: "Main") do
        NavigationMenuList do
          NavigationMenuItem do
            NavigationMenuTrigger { plain "Products"; NavigationMenuIcon() }
            NavigationMenuContent { ul(class: "grid w-96 grid-cols-2 gap-0.5") { instance_exec(PRODUCTS, &CARDS) } }
          end
          NavigationMenuItem do
            NavigationMenuTrigger { plain "Resources"; NavigationMenuIcon() }
            NavigationMenuContent { ul(class: "grid w-50 gap-0.5") { instance_exec(RESOURCES, &CARDS) } }
          end
          NavigationMenuItem { NavigationMenuLink(href: "#!") { "Pricing" } }
        end
      end
    end
  end

  # `:pill` gives triggers a hover background, `:line` an animated underline.
  def variants
    phlex do
      div(class: "flex flex-col gap-8") do
        %i[ pill line ].each { |variant| NavigationMenu(aria_label: variant.to_s, variant:) { NavigationMenuList { instance_exec(&SIMPLE) } } }
      end
    end
  end

  def sizes
    phlex do
      div(class: "flex flex-col gap-6") do
        %i[ sm md lg ].each { |size| NavigationMenu(aria_label: size.to_s, size:) { NavigationMenuList { instance_exec(&SIMPLE) } } }
      end
    end
  end

  # @label Indicator
  # `icon:` - a chevron (default), a caret, or a plus that turns into a minus; `false` drops it.
  def indicator
    phlex do
      div(class: "flex flex-wrap gap-6") do
        %i[ chevron caret plus ].each do |kind|
          NavigationMenu(aria_label: kind.to_s, icon: kind) do
            NavigationMenuList do
              NavigationMenuItem do
                NavigationMenuTrigger { plain kind.to_s; NavigationMenuIcon() }
                NavigationMenuContent { ul(class: "grid w-50 gap-0.5") { %w[ Dashboard Reports Settings ].each { |label| li { NavigationMenuLink(href: "#!") { label } } } } }
              end
            end
          end
        end
      end
    end
  end

  # A sidebar whose panels open to the inline-end side.
  def vertical
    menus = { "Dashboard" => [ :layout_dashboard, %w[ Summary Activity Insights ] ], "Projects" => [ :folder, [ "All projects", "Archived", "Templates" ] ], "Team" => [ :users, %w[ Members Roles Invitations ] ] }
    phlex do
      NavigationMenu(aria_label: "Sidebar", orientation: :vertical, class: "w-48") do
        NavigationMenuList do
          menus.each do |label, (icon, links)|
            NavigationMenuItem do
              NavigationMenuTrigger(class: "w-full justify-start") { Icon(icon, data: { icon: "start" }); plain label; NavigationMenuIcon(class: "ms-auto") }
              NavigationMenuContent { ul(class: "grid w-48 gap-0.5") { links.each { |link| li { NavigationMenuLink(href: "#!") { link } } } } }
            end
          end
        end
      end
    end
  end

  # `backdrop: true` dims and blurs the page behind the open panel.
  def backdrop
    phlex do
      NavigationMenu(aria_label: "Main", backdrop: true) do
        NavigationMenuList do
          NavigationMenuItem do
            NavigationMenuTrigger { plain "Products"; NavigationMenuIcon() }
            NavigationMenuContent { ul(class: "grid w-94 grid-cols-2 gap-0.5") { instance_exec(PRODUCTS.map { |title, description, _| [ title, description ] }, &CARDS) } }
          end
          NavigationMenuItem { NavigationMenuLink(href: "#!") { "Pricing" } }
        end
      end
    end
  end

  # @label Nested submenus
  # A vertical NavigationMenu inside a panel opens its own panel beside it.
  def nested
    phlex do
      NavigationMenu(aria_label: "Main") do
        NavigationMenuList do
          NavigationMenuItem do
            NavigationMenuTrigger { plain "Company"; NavigationMenuIcon() }
            NavigationMenuContent do
              ul(class: "grid w-58 gap-0.5") do
                instance_exec([ [ "About", "Our mission and the team behind it." ], [ "Careers", "Open roles across the company." ], [ "Blog", "Product news and engineering notes." ] ], &CARDS)
                li do
                  NavigationMenu(orientation: :vertical, aria_label: "Handbook") do
                    NavigationMenuList(class: "w-full") do
                      NavigationMenuItem(class: "w-full") do
                        NavigationMenuTrigger(class: "h-auto w-full whitespace-normal") do
                          span(class: "flex min-w-0 flex-1 flex-col items-start gap-0.5") do
                            span(class: "text-foreground-intense font-medium") { "Handbook" }
                            span(class: "text-foreground-muted text-xs font-normal") { "How the team works, day to day." }
                          end
                          NavigationMenuIcon()
                        end
                        NavigationMenuContent do
                          ul(class: "grid w-50 gap-0.5") do
                            instance_exec([ [ "Getting started", "Set up your workspace." ], [ "Principles", "How we make decisions." ], [ "Remote work", "Working across time zones." ] ], &CARDS)
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
          NavigationMenuItem { NavigationMenuLink(href: "#!") { "Pricing" } }
        end
      end
    end
  end

  # @label Nested inline submenus
  # `viewport: false` with a NavigationMenuViewport switches panels inside the same popup;
  # `default_value:` opens a category on load.
  def inline
    audiences = {
      developers: [ "Developers", "Build and ship faster", "APIs, SDKs, and primitives to integrate in minutes.", [ [ "API reference", "Every endpoint, documented." ], [ "SDKs", "First-party libraries for your stack." ], [ "Examples", "Copy-paste starting points." ] ] ],
      designers: [ "Designers", "Design with the system", "Tokens, kits, and guidelines that match the code.", [ [ "Figma kit", "Components mapped to production." ], [ "Design tokens", "One source of truth for theming." ], [ "Guidelines", "Patterns and accessibility notes." ] ] ],
      teams: [ "Teams", "Scale across the org", "Roles, governance, and shared workspaces.", [ [ "Permissions", "Granular role-based access." ], [ "Audit log", "Track every change." ], [ "SSO", "Single sign-on for everyone." ] ] ]
    }
    card = "h-auto flex-col items-start gap-0.5 whitespace-normal"
    phlex do
      NavigationMenu(aria_label: "Main") do
        NavigationMenuList do
          NavigationMenuItem do
            NavigationMenuTrigger { plain "Product"; NavigationMenuIcon() }
            NavigationMenuContent(class: "p-0") do
              NavigationMenu(orientation: :vertical, default_value: "developers", viewport: false, aria_label: "Audiences") do
                div(class: "grid w-125 grid-cols-[13rem_minmax(0,1fr)]") do
                  NavigationMenuList(class: "border-border w-full flex-col items-stretch gap-1 border-e p-2") do
                    audiences.each do |value, (label, hint, description, links)|
                      NavigationMenuItem(value: value.to_s, class: "w-full") do
                        NavigationMenuTrigger(class: "w-full #{card}") do
                          span(class: "text-foreground-intense font-medium") { label }
                          span(class: "text-foreground-muted text-xs font-normal") { hint }
                        end
                        NavigationMenuContent(class: "p-0") do
                          div(class: "flex flex-col gap-3 p-2") do
                            div(class: "px-3 pt-1") do
                              h4(class: "text-foreground-intense m-0 font-semibold") { "For #{label.downcase}" }
                              p(class: "text-foreground-muted m-0 mt-0.5 text-sm") { description }
                            end
                            ul(class: "grid gap-1") do
                              links.each do |title, text|
                                li do
                                  NavigationMenuLink(href: "#!", class: card) do
                                    span(class: "text-foreground-emphasis font-medium") { title }
                                    span(class: "text-foreground-muted text-xs font-normal") { text }
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                  NavigationMenuViewport(class: "min-h-60")
                end
              end
            end
          end
          NavigationMenuItem { NavigationMenuLink(href: "#!") { "Pricing" } }
        end
      end
    end
  end

  # @label RTL
  # Panels open from the start edge of their trigger; the vertical menu opens to the left.
  def rtl
    phlex do
      div(dir: "rtl", class: "flex flex-wrap items-start gap-10") do
        NavigationMenu(aria_label: "رئيسي") do
          NavigationMenuList do
            NavigationMenuItem do
              NavigationMenuTrigger { plain "المنتجات"; NavigationMenuIcon() }
              NavigationMenuContent { ul(class: "grid w-50 gap-0.5") { %w[ التحليلات المكونات الأتمتة ].each { |label| li { NavigationMenuLink(href: "#!") { label } } } } }
            end
            NavigationMenuItem { NavigationMenuLink(href: "#!") { "الأسعار" } }
          end
        end
      end
    end
  end
end
