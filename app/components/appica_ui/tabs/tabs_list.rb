# The row (or column) of TabsTriggers, with the sliding active indicator. `variant:` / `size:`
# override the root's; `activate_on_focus: true` switches panels as the arrow keys move focus;
# `loop_focus: false` stops at the ends.
class AppicaUI::TabsList < AppicaUI::Base
  LIST = "relative flex w-fit items-center justify-center data-[orientation=vertical]:h-fit data-[orientation=vertical]:flex-col"
  VARIANTS = { pill: "gap-0.5 p-0.5 bg-background-muted", line: "" }.freeze
  SIZES = { sm: "data-[orientation=vertical]:min-w-32", md: "data-[orientation=vertical]:min-w-36", lg: "data-[orientation=vertical]:min-w-40" }.freeze
  COMPOUND = {
    pill: { sm: "rounded-sm", md: "rounded-md", lg: "rounded-lg" },
    line: { sm: "data-[orientation=horizontal]:gap-5", md: "data-[orientation=horizontal]:gap-6", lg: "data-[orientation=horizontal]:gap-7" }
  }.freeze

  INDICATOR = "absolute z-0 inset-s-0 transition-[translate,width,height] duration-250 motion-reduce:transition-none " \
    "data-[orientation=horizontal]:ltr:translate-x-(--active-tab-left) data-[orientation=horizontal]:rtl:-translate-x-(--active-tab-right) data-[orientation=vertical]:translate-y-(--active-tab-top)"
  INDICATORS = {
    pill: "w-(--active-tab-width) data-[orientation=horizontal]:top-0.5 data-[orientation=horizontal]:h-[calc(100%-0.25rem)] data-[orientation=vertical]:top-0 " \
      "data-[orientation=vertical]:bottom-(--active-tab-bottom) data-[orientation=vertical]:inset-s-0.5 data-[orientation=vertical]:h-(--active-tab-height) rounded-[inherit] bg-white dark:bg-background-strong shadow-lg",
    line: "rounded-full bg-foreground-intense data-[orientation=horizontal]:bottom-0 data-[orientation=horizontal]:h-0.5 data-[orientation=horizontal]:w-(--active-tab-width) " \
      "data-[orientation=vertical]:top-[calc(var(--active-tab-height)/4)] data-[orientation=vertical]:h-[calc(var(--active-tab-height)/2)] data-[orientation=vertical]:w-0.5"
  }.freeze

  prop :variant,           default: -> { nil }
  prop :size,              default: -> { nil }
  prop :activate_on_focus, default: -> { false }
  prop :loop_focus,        default: -> { true }

  attr_reader :variant, :size

  def view_template(&)
    tabs = consume(:ui_tabs, component: "Tabs")
    @variant = (@variant || tabs.variant).to_sym
    @size = (@size || tabs.size).to_sym
    orientation = tabs.orientation

    provide(:ui_tabs_list, self) do
      div(**mix({
        role: "tablist", aria_orientation: ("vertical" if orientation == :vertical),
        data: {
          slot: "tabs-list", orientation:, "appica-ui--tabs-target": "list",
          "appica-ui--tabs-activate-on-focus-param": @activate_on_focus.to_s, "appica-ui--tabs-loop-param": @loop_focus.to_s,
          action: "keydown->appica-ui--tabs#navigate focusin->appica-ui--tabs#focus"
        }
      }, @attributes.except(:class)), class: cn(LIST, VARIANTS[@variant], SIZES[@size], COMPOUND[@variant][@size], override: @attributes[:class])) do
        span(role: "presentation", hidden: true, data: { slot: "tabs-indicator", orientation:, "appica-ui--tabs-target": "indicator" }, class: "#{INDICATOR} #{INDICATORS[@variant]}")
        yield
      end
    end
  end
end
