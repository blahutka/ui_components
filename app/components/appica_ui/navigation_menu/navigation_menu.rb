# Site navigation whose items open rich panels of links - Appica's mega-menu.
#
#   NavigationMenu(aria_label: "Main") do
#     NavigationMenuList do
#       NavigationMenuItem do
#         NavigationMenuTrigger { plain "Products"; NavigationMenuIcon() }
#         NavigationMenuContent do
#           ul(class: "grid w-96 grid-cols-2 gap-0.5") { li { NavigationMenuLink(href: "/analytics") { "Analytics" } } }
#         end
#       end
#       NavigationMenuItem { NavigationMenuLink(href: "/pricing") { "Pricing" } }
#     end
#   end
#
# The root shares `variant:` (:pill, :line), `size:`, `orientation:` and the trigger `icon:`
# (:chevron, :caret, :plus, false). Panels are rendered on the server, hidden in their items; the
# `appica-ui--navigation-menu` controller moves the open one into a shared popup in the top layer,
# positions it under its trigger (beside it when vertical) and morphs the popup between panels.
# `backdrop: true` dims the page behind it. `viewport: false` with your own NavigationMenuViewport
# switches panels inline (a nested category sidebar); `default_value:` opens an item on load.
class AppicaUI::NavigationMenu < AppicaUI::Base
  POPUP = "bg-background border-border-overlay fixed inset-auto m-0 hidden open:block overflow-visible border p-0 shadow-2xl outline-none " \
    "motion-safe:transition-[opacity,scale] motion-safe:duration-300 motion-safe:ease-[cubic-bezier(0.175,0.885,0.32,1.5)] " \
    "data-morph:motion-safe:[transition:opacity_300ms_cubic-bezier(0.175,0.885,0.32,1.5),scale_300ms_cubic-bezier(0.175,0.885,0.32,1.5),width_300ms_cubic-bezier(0.22,1,0.36,1),height_300ms_cubic-bezier(0.22,1,0.36,1),top_300ms_cubic-bezier(0.22,1,0.36,1),left_300ms_cubic-bezier(0.22,1,0.36,1)] " \
    "data-instant:motion-safe:transition-none " \
    "data-starting-style:motion-safe:scale-95 data-starting-style:motion-safe:opacity-0 " \
    "data-ending-style:motion-safe:scale-95 data-ending-style:motion-safe:opacity-0 data-ending-style:motion-safe:duration-150 data-ending-style:motion-safe:ease-out"
  POPUP_RADIUS = { sm: "rounded-md", md: "rounded-lg", lg: "rounded-xl" }.freeze
  BACKDROP = "pointer-events-none fixed inset-0 z-40 bg-black/30 backdrop-blur-sm motion-safe:transition-opacity motion-safe:duration-250 motion-safe:ease-out " \
    "opacity-0 data-open:opacity-100"

  prop :variant,       one_of(%i[ pill line ], :pill), default: -> { :pill }
  prop :size,          one_of(%i[ sm md lg ], :md), default: -> { :md }
  prop :orientation,   one_of(%i[ horizontal vertical ], :horizontal), default: -> { :horizontal }
  prop :icon,          default: -> { :chevron }
  prop :morph,         default: -> { true }
  prop :backdrop,      default: -> { false }
  prop :viewport,      default: -> { true }
  prop :side_offset,   default: -> { nil }
  prop :default_value, default: -> { nil }
  prop :delay,         default: -> { 50 }
  prop :close_delay,   default: -> { 50 }
  prop :id,            default: -> { "navigation-menu-#{SecureRandom.hex(4)}" }

  attr_reader :variant, :size, :orientation, :icon, :id

  def backdrop? = @backdrop
  def nested? = @nested
  def open?(value) = !@default_value.nil? && @default_value.to_s == value.to_s

  def view_template(&)
    # Inside another menu's panel: a submenu (opens further out, keeps its triggers pill-shaped)
    @nested = context[:ui_navigation_menu_content].present?

    provide(:ui_navigation_menu, self) do
      provide(:ui_navigation_menu_content, nil) do
        nav(**mix(defaults(
          id: @id,
          data: {
            slot: "navigation-menu", orientation: @orientation, controller: "appica-ui--navigation-menu",
            "appica-ui--navigation-menu-delay-value": @delay, "appica-ui--navigation-menu-close-delay-value": @close_delay,
            "appica-ui--navigation-menu-side-offset-value": @side_offset || (@nested ? 12 : 6),
            "appica-ui--navigation-menu-orientation-value": @orientation, "appica-ui--navigation-menu-inline-value": (!@viewport).to_s,
            "appica-ui--navigation-menu-default-value-value": @default_value&.to_s,
            action: "keydown->appica-ui--navigation-menu#key focusout->appica-ui--navigation-menu#focusOut pointerleave->appica-ui--navigation-menu#leave pointerenter->appica-ui--navigation-menu#enter"
          }
        ), @attributes.except(:class)), class: @attributes[:class]) do
          yield
          popup if @viewport
        end
      end
    end
  end

  private
    def popup
      div(class: BACKDROP, data: { slot: "navigation-menu-backdrop", "appica-ui--navigation-menu-target": "backdrop" }) if @backdrop
      div(popover: "manual", tabindex: "-1", role: "presentation",
        data: { slot: "navigation-menu-popup", morph: ("" if @morph), "appica-ui--navigation-menu-target": "popup",
          action: "pointerenter->appica-ui--navigation-menu#enter pointerleave->appica-ui--navigation-menu#leave" },
        class: "#{POPUP} #{POPUP_RADIUS[@size]}") do
        div(data: { slot: "navigation-menu-viewport", "appica-ui--navigation-menu-target": "viewport" }, class: "relative h-full w-full overflow-hidden *:w-max")
      end
    end
end
