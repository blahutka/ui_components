# Links between pages or sections, with the current one highlighted.
#
#   Navigation(aria_label: "Main", active_link: "projects") do
#     NavigationList do
#       NavigationItem { NavigationLink(href: dashboard_path, value: "dashboard") { "Dashboard" } }
#       NavigationItem { NavigationLink(href: projects_path, value: "projects") { "Projects" } }
#     end
#   end
#
# The root `<nav>` shares `variant:` (:pill, :line, or :indicator for vertical docs sidebars),
# `size:` and `orientation:` with its links. The current link is the one whose `value:` matches
# `active_link:`, or one marked `active: true` (e.g. `active: current_page?(path)`); it gets
# aria-current="page". No JavaScript - the highlight comes from the server.
class UI::Navigation < UI::Base
  VARIANTS = %i[ pill line indicator ].freeze

  LISTS = {
    pill: { horizontal: "flex gap-0.5", vertical: "flex flex-col gap-0.5" },
    line: { horizontal: "flex gap-7", vertical: "flex flex-col gap-0.5" },
    indicator: { horizontal: "flex gap-0.5", vertical: "flex flex-col" }
  }.freeze

  prop :variant,     one_of(VARIANTS, :pill), default: -> { :pill }
  prop :size,        one_of(UI::Menubar::SIZES, :md), default: -> { :md }
  prop :orientation, one_of(%i[ horizontal vertical ], :horizontal), default: -> { :horizontal }
  prop :active_link, default: -> { nil }

  attr_reader :variant, :size, :orientation

  def active?(value)
    !value.nil? && !@active_link.nil? && value.to_s == @active_link.to_s
  end

  def list_classes
    LISTS[@variant][@orientation]
  end

  def view_template(&)
    provide(:ui_navigation, self) do
      nav(**mix({ data: { slot: "navigation", variant: @variant, size: @size, orientation: @orientation } }, @attributes.except(:class)),
        class: @attributes[:class], &)
    end
  end
end
