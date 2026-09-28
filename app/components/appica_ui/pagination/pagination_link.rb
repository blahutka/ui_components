# A page link (Button-styled). `active: true` is the current page - filled, aria-current="page"
# and not clickable; `disabled: true` dims an out-of-range control and removes it from the tab
# order. `icon: true` squares it around a lone icon (label it). A block taking an argument
# receives the attributes for your own element (a `button_to`, a Turbo frame link…).
class AppicaUI::PaginationLink < AppicaUI::Base
  VARIANTS = { outline: AppicaUI::Button::VARIANTS[:outline], soft: AppicaUI::Button::VARIANTS[:soft] }.freeze
  SIZES = {
    sm: "h-8 rounded-sm [&_svg:not([class*='size-'])]:size-4 px-2 gap-0.5 text-xs min-w-8 has-data-[icon=end]:pe-1 has-data-[icon=start]:ps-1",
    md: "h-10 rounded-md [&_svg:not([class*='size-'])]:size-4.5 px-2.5 gap-0.5 text-sm min-w-10 has-data-[icon=end]:pe-1.5 has-data-[icon=start]:ps-1.5",
    lg: "h-12 rounded-lg [&_svg:not([class*='size-'])]:size-5 px-3 gap-0.5 text-base min-w-12 has-data-[icon=end]:pe-2 has-data-[icon=start]:ps-2"
  }.freeze
  CURRENT = "text-primary-foreground pointer-events-none cursor-default before:bg-primary before:border-transparent"
  DISABLED = "opacity-disabled pointer-events-none"

  prop :active,   default: -> { false }
  prop :disabled, default: -> { false }
  prop :icon,     default: -> { false }

  def before_template(&content)
    @render_prop = content&.arity == 1
    super
  end

  def view_template(&)
    pagination = consume(:ui_pagination, component: "Pagination")
    attributes = mix({
      aria_current: ("page" if @active), aria_disabled: ("true" if @disabled), tabindex: ("-1" if @disabled),
      data: { slot: "pagination-link", variant: pagination.variant, size: pagination.size, active: ("true" if @active), disabled: ("" if @disabled) }
    }.compact, @attributes.except(:class))
    classes = cn(AppicaUI::Button::BASE, VARIANTS[pagination.variant], SIZES[pagination.size], (CURRENT if @active), (DISABLED if @disabled), ("px-0" if @icon),
      override: @attributes[:class])

    if @render_prop
      yield attributes.merge(class: classes)
    else
      a(**attributes, class: classes, &)
    end
  end
end
