# One tab (`<button role="tab">`) for the TabsContent with the same `value:`. `disabled: true`
# skips it; `icon: true` makes a square, label-less tab (give it an aria_label:).
class AppicaUI::TabsTrigger < AppicaUI::Base
  TRIGGER = "group/trigger relative flex shrink-0 cursor-pointer items-stretch data-[orientation=vertical]:w-full text-foreground-strong font-medium select-none outline-ring " \
    "transition-colors duration-250 motion-reduce:transition-none hover:text-foreground-intense data-active:pointer-events-none data-disabled:opacity-disabled data-disabled:pointer-events-none " \
    "[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='stroke-'])]:stroke-[1.85]"
  VARIANTS = { pill: "data-active:text-black dark:data-active:text-foreground-intense", line: "data-active:text-foreground-intense" }.freeze
  SIZES = { sm: "text-xs [&_svg:not([class*='size-'])]:size-4", md: "text-sm [&_svg:not([class*='size-'])]:size-4.5", lg: "text-base [&_svg:not([class*='size-'])]:size-5" }.freeze
  PILL_RADIUS = { sm: "rounded-sm", md: "rounded-md", lg: "rounded-lg" }.freeze

  INNER = "relative isolate flex items-center data-[orientation=horizontal]:justify-center data-[orientation=vertical]:w-full data-[orientation=horizontal]:text-center data-[orientation=vertical]:text-start " \
    "data-[orientation=horizontal]:whitespace-nowrap transform-gpu transition-transform duration-250 ease-[cubic-bezier(0.175,0.885,0.32,1.5)] motion-reduce:transition-none " \
    "group-active/trigger:scale-[0.97] group-active/trigger:duration-100 group-active/trigger:ease-in-out group-active/trigger:translate-y-px"
  INNER_PILL = "before:absolute before:inset-0 before:-z-1 before:rounded-[inherit] before:pointer-events-none before:transition-colors before:duration-250 " \
    "group-hover/trigger:before:bg-background-subtle motion-reduce:before:transition-none supports-[font:-apple-system-body]:before:hidden"
  INNER_SIZES = { sm: "gap-1 py-2", md: "gap-1.5 py-2.5", lg: "gap-1.5 py-3" }.freeze
  INNER_ICON_SIZES = { sm: "size-8", md: "size-10", lg: "size-12" }.freeze
  INNER_COMPOUND = {
    pill: {
      sm: "rounded-sm px-3.5 has-data-[icon=end]:pe-2.5 has-data-[icon=start]:ps-2.5",
      md: "rounded-md px-4.5 has-data-[icon=end]:pe-3 has-data-[icon=start]:ps-3",
      lg: "rounded-lg px-5.5 has-data-[icon=end]:pe-4 has-data-[icon=start]:ps-4"
    },
    line: {
      sm: "data-[orientation=vertical]:ps-3 data-[orientation=vertical]:has-data-[icon=end]:pe-2 data-[orientation=vertical]:has-data-[icon=start]:ps-2",
      md: "data-[orientation=vertical]:ps-4 data-[orientation=vertical]:has-data-[icon=end]:pe-3 data-[orientation=vertical]:has-data-[icon=start]:ps-3",
      lg: "data-[orientation=vertical]:ps-5 data-[orientation=vertical]:has-data-[icon=end]:pe-4 data-[orientation=vertical]:has-data-[icon=start]:ps-4"
    }
  }.freeze

  prop :value
  prop :disabled, default: -> { false }
  prop :icon,     default: -> { false }
  prop :variant,  default: -> { nil }
  prop :size,     default: -> { nil }

  def view_template(&)
    tabs = consume(:ui_tabs, component: "Tabs")
    list = context[:ui_tabs_list]
    variant = (@variant || list&.variant || tabs.variant).to_sym
    size = (@size || list&.size || tabs.size).to_sym
    selected = tabs.selected?(@value)

    button(**mix({
      type: "button", role: "tab", id: tabs.trigger_id(@value), aria_selected: selected.to_s, aria_controls: tabs.panel_id(@value),
      aria_disabled: ("true" if @disabled), disabled: (true if @disabled), tabindex: (selected ? "0" : "-1"),
      data: {
        slot: "tabs-trigger", orientation: tabs.orientation, active: ("" if selected), disabled: ("" if @disabled), value: @value.to_s,
        "appica-ui--tabs-target": "trigger", action: "appica-ui--tabs#select"
      }
    }, @attributes.except(:class)),
      class: cn(TRIGGER, VARIANTS[variant], SIZES[size], (PILL_RADIUS[size] if variant == :pill), override: @attributes[:class])) do
      span(data: { slot: "tabs-trigger-inner", orientation: tabs.orientation },
        class: cn(INNER, (INNER_PILL if variant == :pill), (@icon ? INNER_ICON_SIZES[size] : INNER_SIZES[size]),
          (@icon ? PILL_RADIUS[size] : INNER_COMPOUND[variant][size]), ("justify-center" if @icon)), &)
    end
  end
end
