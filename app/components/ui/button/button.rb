# Appica's Button. Renders an <a> when given `href:`.
#
#   Button { "Save" }
#   Button(variant: :outline, size: :sm) { "Cancel" }
#   Button(variant: :soft, icon: true, aria_label: "Bookmark") { bookmark_svg }
class UI::Button < UI::Base
  BASE = "relative isolate inline-flex shrink-0 transform-gpu cursor-pointer items-center justify-center font-medium whitespace-nowrap outline-offset-1 transition duration-250 ease-[cubic-bezier(0.175,0.885,0.32,1.5)] select-none " \
    "not-data-popup-open:active:scale-[0.97] not-data-popup-open:active:duration-100 not-data-popup-open:active:ease-in-out not-data-popup-open:active:translate-y-px " \
    "data-disabled:opacity-disabled data-disabled:pointer-events-none disabled:opacity-disabled disabled:pointer-events-none motion-reduce:transition-none " \
    "[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='stroke-'])]:stroke-[1.85] " \
    "before:pointer-events-none before:absolute before:inset-0 before:-z-1 before:rounded-[inherit] before:transition-[opacity,background-color,border-color] before:duration-300 motion-reduce:before:transition-none"

  VARIANTS = {
    primary: "text-primary-foreground bg-primary before:bg-[radial-gradient(138.15%_78.13%_at_52.05%_50%,var(--primary)_0%,var(--primary-muted)_80%)] before:opacity-0 hover:before:opacity-100 outline-ring-primary data-popup-open:before:opacity-100 data-pressed:before:opacity-100",
    primary_outline: "text-primary before:border before:border-primary hover:text-primary-foreground hover:before:bg-primary outline-ring-primary data-popup-open:before:bg-primary data-pressed:before:bg-primary data-popup-open:text-primary-foreground data-pressed:text-primary-foreground",
    secondary: "text-secondary-foreground bg-secondary outline-ring-secondary before:bg-[radial-gradient(138.15%_78.13%_at_52.05%_50%,var(--secondary)_0%,var(--secondary-muted)_95%)] before:opacity-0 hover:before:opacity-100 data-popup-open:before:opacity-100 data-pressed:before:opacity-100",
    soft: "text-foreground-emphasis hover:text-foreground-intense before:bg-background-muted hover:before:bg-background-subtle hover:before:border-border data-popup-open:text-foreground-intense data-pressed:text-foreground-intense data-popup-open:before:bg-background-subtle data-pressed:before:bg-background-subtle data-popup-open:before:border-border data-pressed:before:border-border outline-ring before:border before:border-transparent before:backdrop-blur-md",
    outline: "bg-background text-foreground-emphasis hover:text-foreground-intense before:bg-background before:border-border hover:before:bg-background-subtle hover:before:border-border-strong data-popup-open:text-foreground-intense data-pressed:text-foreground-intense data-popup-open:before:bg-background-subtle data-pressed:before:bg-background-subtle data-popup-open:before:border-border-strong data-pressed:before:border-border-strong outline-ring before:border",
    ghost: "text-foreground-emphasis hover:text-foreground-intense hover:before:bg-background-muted data-popup-open:text-foreground-intense data-pressed:text-foreground-intense data-popup-open:before:bg-background-muted data-pressed:before:bg-background-muted outline-ring",
    destructive: "text-error-foreground bg-error outline-ring-error before:bg-[radial-gradient(138.15%_78.13%_at_52.05%_50%,var(--error)_0%,var(--error-muted)_95%)] before:opacity-0 hover:before:opacity-100 data-popup-open:before:opacity-100 data-pressed:before:opacity-100",
    # For controls over imagery or dark surfaces: a translucent white fill
    light: "text-white before:bg-white/10 before:border-white/10 before:border before:backdrop-blur-md hover:before:bg-white/15 hover:before:border-white/15 outline-ring-light data-popup-open:before:bg-white/15 data-pressed:before:bg-white/15 data-popup-open:before:border-white/15 data-pressed:before:border-white/15"
  }.freeze

  SIZES = {
    sm: "h-8 gap-1 rounded-sm px-4 text-xs has-data-[icon=end]:pe-3 has-data-[icon=start]:ps-3 [&_svg:not([class*='size-'])]:size-4",
    md: "h-10 gap-1.5 rounded-md px-5 text-sm has-data-[icon=end]:pe-3.5 has-data-[icon=start]:ps-3.5 [&_svg:not([class*='size-'])]:size-4.5",
    lg: "h-12 gap-2 rounded-lg px-6 text-base has-data-[icon=end]:pe-4.5 has-data-[icon=start]:ps-4.5 [&_svg:not([class*='size-'])]:size-5"
  }.freeze

  ICON_SIZES = {
    sm: "size-8 rounded-sm [&_svg:not([class*='size-'])]:size-4",
    md: "size-10 rounded-md [&_svg:not([class*='size-'])]:size-4.5",
    lg: "size-12 rounded-lg [&_svg:not([class*='size-'])]:size-5"
  }.freeze

  prop :variant, one_of(VARIANTS, :primary), default: -> { :primary }
  prop :size,    one_of(SIZES, :md), default: -> { :md }
  prop :icon,    default: -> { false }

  def view_template(&)
    classes = cn(BASE, VARIANTS[@variant], (@icon ? ICON_SIZES : SIZES)[@size], override: @attributes[:class])
    attributes = @attributes.except(:class)
    # Keep the slot of a part projected onto the button (e.g. "drawer-trigger")
    attributes = mix({ data: { slot: "button" } }, attributes) unless attributes.dig(:data, :slot)

    if attributes[:href]
      a(**attributes, class: classes, &)
    else
      button(**{ type: "button" }.merge(attributes), class: classes, &)
    end
  end
end
