# A bar of menus for an app's top-level commands (File / Edit / View …).
#
#   Menubar(aria_label: "Application") do
#     MenubarMenu do
#       MenubarTrigger { "File" }
#       MenubarContent do
#         MenubarItem { "New file" }
#         MenubarSub do
#           MenubarSubTrigger { "Open recent" }
#           MenubarSubContent { MenubarItem { "project-alpha" } }
#         end
#         MenubarSeparator()
#         MenubarItem { "Save" }
#       end
#     end
#   end
#
# The bar shares `variant:`, `size:` and `orientation:` with every menu. Behaviour (opening,
# hover-switching, submenus, keyboard navigation, typeahead, checkbox/radio state) lives in
# the `ui--menubar` Stimulus controller.
class UI::Menubar < UI::Base
  # Triggers and items share one look: a text row with a hover/highlight pill
  ROW = "relative inline-flex items-center gap-1.5 transform-gpu cursor-pointer font-medium transition duration-250 ease-[cubic-bezier(0.175,0.885,0.32,1.5)] select-none " \
    "not-data-popup-open:active:scale-[0.97] not-data-popup-open:active:duration-100 not-data-popup-open:active:ease-in-out not-data-popup-open:active:translate-y-px " \
    "data-disabled:opacity-disabled data-disabled:pointer-events-none motion-reduce:transition-none data-[orientation=vertical]:text-start " \
    "[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='stroke-'])]:stroke-[1.85] " \
    "text-foreground-strong hover:text-foreground-intense focus-visible:text-foreground-intense data-active:text-foreground-intense data-popup-open:text-foreground-intense data-pressed:text-foreground-intense outline-hidden"

  PILL = "before:pointer-events-none before:absolute before:inset-0 before:-z-1 before:rounded-[inherit] before:transition-colors before:duration-300 motion-reduce:before:transition-none " \
    "hover:before:bg-background-muted focus-visible:before:bg-background-muted data-active:before:bg-background-muted data-popup-open:before:bg-background-muted data-pressed:before:bg-background-muted " \
    "data-highlighted:not-data-disabled:text-foreground-intense data-highlighted:not-data-disabled:before:bg-background-muted"

  PILL_SIZES = {
    sm: "text-xs [&_svg:not([class*='size-'])]:size-4 data-[orientation=horizontal]:rounded-sm data-[orientation=horizontal]:py-2 data-[orientation=horizontal]:px-3 data-[orientation=horizontal]:has-data-[icon=end]:pe-2 data-[orientation=horizontal]:has-data-[icon=start]:ps-2 " \
      "data-[orientation=vertical]:rounded-xs data-[orientation=vertical]:py-1.5 data-[orientation=vertical]:px-2.5 data-[orientation=vertical]:has-data-[icon=end]:pe-1.5 data-[orientation=vertical]:has-data-[icon=start]:ps-1.5",
    md: "text-sm [&_svg:not([class*='size-'])]:size-4.5 data-[orientation=horizontal]:rounded-md data-[orientation=horizontal]:py-2.5 data-[orientation=horizontal]:px-3.5 data-[orientation=horizontal]:has-data-[icon=end]:pe-2.5 data-[orientation=horizontal]:has-data-[icon=start]:ps-2.5 " \
      "data-[orientation=vertical]:rounded-sm data-[orientation=vertical]:py-2 data-[orientation=vertical]:px-3 data-[orientation=vertical]:has-data-[icon=end]:pe-2 data-[orientation=vertical]:has-data-[icon=start]:ps-2",
    lg: "text-base [&_svg:not([class*='size-'])]:size-5 data-[orientation=horizontal]:rounded-lg data-[orientation=horizontal]:py-3 data-[orientation=horizontal]:px-4 data-[orientation=horizontal]:has-data-[icon=end]:pe-3 data-[orientation=horizontal]:has-data-[icon=start]:ps-3 " \
      "data-[orientation=vertical]:rounded-md data-[orientation=vertical]:py-2.5 data-[orientation=vertical]:px-3.5 data-[orientation=vertical]:has-data-[icon=end]:pe-2.5 data-[orientation=vertical]:has-data-[icon=start]:ps-2.5"
  }.freeze

  # The `line` variant: an underline (or a side bar when vertical) that draws in on hover/open
  LINE = "after:absolute after:rounded-full after:bg-no-repeat after:[background-image:linear-gradient(0deg,currentColor,currentColor)] after:transition-[background-size] after:duration-300 motion-reduce:after:transition-none " \
    "data-[orientation=horizontal]:after:inset-x-0 data-[orientation=horizontal]:after:h-0.5 data-[orientation=horizontal]:after:bg-size-[0_2px] ltr:data-[orientation=horizontal]:after:bg-right rtl:data-[orientation=horizontal]:after:bg-left " \
    "hover:data-[orientation=horizontal]:after:bg-size-[100%_2px] focus-visible:data-[orientation=horizontal]:after:bg-size-[100%_2px] ltr:hover:data-[orientation=horizontal]:after:bg-left rtl:hover:data-[orientation=horizontal]:after:bg-right " \
    "ltr:focus-visible:data-[orientation=horizontal]:after:bg-left rtl:focus-visible:data-[orientation=horizontal]:after:bg-right " \
    "data-popup-open:data-[orientation=horizontal]:after:bg-size-[100%_2px] ltr:data-popup-open:data-[orientation=horizontal]:after:bg-left rtl:data-popup-open:data-[orientation=horizontal]:after:bg-right " \
    "data-[orientation=vertical]:after:inset-s-0 data-[orientation=vertical]:after:top-[25%] data-[orientation=vertical]:after:bottom-[25%] data-[orientation=vertical]:after:w-0.5 data-[orientation=vertical]:after:bg-size-[2px_0] data-[orientation=vertical]:after:[background-position-y:bottom] " \
    "hover:data-[orientation=vertical]:after:bg-size-[2px_100%] hover:data-[orientation=vertical]:after:[background-position-y:top] focus-visible:data-[orientation=vertical]:after:bg-size-[2px_100%] focus-visible:data-[orientation=vertical]:after:[background-position-y:top] " \
    "data-popup-open:data-[orientation=vertical]:after:bg-size-[2px_100%] data-popup-open:data-[orientation=vertical]:after:[background-position-y:top]"

  LINE_SIZES = {
    sm: "text-xs [&_svg:not([class*='size-'])]:size-4 data-[orientation=horizontal]:py-2 data-[orientation=vertical]:py-1.5 data-[orientation=vertical]:ps-2.5 data-[orientation=vertical]:has-data-[icon=start]:ps-2 data-[orientation=horizontal]:after:bottom-1",
    md: "text-sm [&_svg:not([class*='size-'])]:size-4.5 data-[orientation=horizontal]:py-2.5 data-[orientation=vertical]:py-2 data-[orientation=vertical]:ps-3 data-[orientation=vertical]:has-data-[icon=end]:pe-2 data-[orientation=vertical]:has-data-[icon=start]:ps-2.5 data-[orientation=horizontal]:after:bottom-1.5",
    lg: "text-base [&_svg:not([class*='size-'])]:size-5 data-[orientation=horizontal]:py-3 data-[orientation=vertical]:py-2.5 data-[orientation=vertical]:ps-3.5 data-[orientation=vertical]:has-data-[icon=start]:ps-3 data-[orientation=horizontal]:after:bottom-2"
  }.freeze

  BAR = {
    pill: { horizontal: "flex w-fit items-center gap-0.5", vertical: "flex flex-col items-stretch gap-0.5" },
    line: { horizontal: "flex w-fit items-center gap-7", vertical: "flex flex-col items-stretch gap-1" }
  }.freeze

  POPUP = "bg-background border-border-overlay absolute z-50 flex min-w-48 flex-col border shadow-2xl outline-none " \
    "motion-safe:transition-[opacity,scale] motion-safe:duration-200 motion-safe:ease-[cubic-bezier(0.175,0.885,0.32,1.5)] " \
    "data-starting-style:motion-safe:scale-90 data-starting-style:motion-safe:opacity-0 data-ending-style:motion-safe:scale-95 data-ending-style:motion-safe:opacity-0 data-ending-style:motion-safe:duration-100 data-ending-style:motion-safe:ease-out"

  POPUP_RADIUS = { sm: "rounded-md", md: "rounded-lg", lg: "rounded-xl" }.freeze

  VARIANTS = %i[ pill line ].freeze
  SIZES = %i[ sm md lg ].freeze

  prop :variant,     one_of(VARIANTS, :pill), default: -> { :pill }
  prop :size,        one_of(SIZES, :md), default: -> { :md }
  prop :orientation, one_of(%i[ horizontal vertical ], :horizontal), default: -> { :horizontal }
  prop :loop_focus,  default: -> { true }
  prop :disabled,    default: -> { false }

  attr_reader :variant, :size, :orientation

  def view_template(&)
    provide(:ui_menubar, self) do
      div(**mix({
        role: "menubar",
        aria: { orientation: },
        data: {
          slot: "menubar",
          orientation:,
          disabled: (@disabled ? "" : nil),
          controller: "ui--menubar",
          "ui--menubar-loop-value": @loop_focus.to_s,
          action: "keydown->ui--menubar#navigate focusin->ui--menubar#highlight pointerdown@window->ui--menubar#dismiss"
        }
      }, @attributes.except(:class)), class: cn(BAR[variant][orientation], override: @attributes[:class]), &)
    end
  end

  def vertical? = orientation == :vertical
  def disabled? = @disabled

  # Classes for a menu row (trigger or item) in this bar
  def trigger_classes
    variant == :line ? [ ROW, LINE, LINE_SIZES[size] ] : [ ROW, PILL, PILL_SIZES[size] ]
  end

  def item_classes
    [ ROW, PILL, PILL_SIZES[size], "w-full" ]
  end

  def popup_classes
    [ POPUP, POPUP_RADIUS[size] ]
  end

  def label_classes
    { sm: "px-2.5 pt-1.5 pb-1 text-xs", md: "px-3 pt-2 pb-1.25 text-sm", lg: "px-3.5 pt-2.5 pb-1.5 text-base" }[size]
  end
end
