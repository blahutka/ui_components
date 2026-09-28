# A small label that highlights a status, count, or category.
#
#   Badge(variant: :success) { "Active" }
#   Badge(variant: :soft, href: "#design") { "Design" }        # interactive link
#   Badge(variant: :primary_outline, as: :button) { "Follow" } # interactive button
#
# Renders a <span>; `href:` makes it an <a> and `as: :button` a <button>, which also
# turns on the hover/press affordances (Appica's `render` prop). Tag an icon with
# `data: { icon: "start" }` / `data: { icon: "end" }` to tighten the padding on that side.
class AppicaUI::Badge < AppicaUI::Base
  BASE = "isolate inline-flex shrink-0 items-center justify-center rounded-full whitespace-nowrap outline-offset-1 select-none [&_svg]:shrink-0 " \
    "[a,button]:transform-gpu [a,button]:cursor-pointer [a,button]:transition [a,button]:duration-250 [a,button]:ease-[cubic-bezier(0.175,0.885,0.32,1.5)] " \
    "[a,button]:not-data-popup-open:active:translate-y-px [a,button]:not-data-popup-open:active:scale-[0.97] [a,button]:not-data-popup-open:active:duration-100 [a,button]:not-data-popup-open:active:ease-in-out motion-reduce:[a,button]:transition-none " \
    "before:pointer-events-none before:absolute before:inset-0 before:-z-1 before:rounded-[inherit] [a,button]:before:transition-[opacity,background-color,border-color] [a,button]:before:duration-250 motion-reduce:[a,button]:before:transition-none"

  # Solid schemes light up with a radial gradient on hover when interactive
  GLOW = "[a,button]:before:opacity-0 [a,button]:hover:before:opacity-100 [a,button]:data-pressed:before:opacity-100 [a,button]:data-popup-open:before:opacity-100"

  # Crumbs projected onto a badge stay muted until hovered or current (BreadcrumbLink)
  BREADCRUMB = "data-[slot=breadcrumb-link]:not-data-active:text-foreground-muted data-[slot=breadcrumb-link]:hover:text-foreground-intense"

  VARIANTS = {
    primary: "relative bg-primary text-primary-foreground outline-ring-primary [a,button]:before:bg-[radial-gradient(138.15%_78.13%_at_52.05%_50%,var(--primary)_0%,var(--primary-muted)_75%)] #{GLOW}",
    primary_outline: "relative text-primary before:border before:border-primary outline-ring-primary [a,button]:hover:before:bg-primary [a,button]:hover:text-primary-foreground [a,button]:data-pressed:before:bg-primary [a,button]:data-pressed:text-primary-foreground [a,button]:data-popup-open:before:bg-primary [a,button]:data-popup-open:text-primary-foreground",
    secondary: "relative bg-secondary-muted text-secondary-foreground outline-ring-secondary [a,button]:before:bg-[radial-gradient(138.15%_78.13%_at_52.05%_50%,var(--secondary)_0%,var(--secondary-muted)_95%)] #{GLOW}",
    soft: "relative text-foreground-intense before:bg-background-muted before:backdrop-blur-md [a,button]:before:border [a,button]:before:border-transparent outline-ring " \
      "#{BREADCRUMB} " \
      "[a,button]:hover:before:bg-background-subtle [a,button]:hover:before:border-border [a,button]:data-pressed:before:bg-background-subtle [a,button]:data-pressed:before:border-border " \
      "[a,button]:data-popup-open:before:bg-background-subtle [a,button]:data-popup-open:before:border-border data-active:before:bg-background-subtle data-active:border data-active:before:border-border",
    outline: "relative bg-background text-foreground-intense before:bg-background before:border-border before:border outline-ring " \
      "#{BREADCRUMB} " \
      "[a,button]:hover:before:bg-background-subtle [a,button]:hover:before:border-border-strong [a,button]:data-pressed:before:bg-background-subtle [a,button]:data-pressed:before:border-border-strong " \
      "[a,button]:data-popup-open:before:bg-background-subtle [a,button]:data-popup-open:before:border-border-strong data-active:before:bg-background-subtle data-active:before:border-border-strong",
    error: "relative bg-error-muted text-error-foreground outline-ring-error [a,button]:before:bg-[radial-gradient(138.15%_78.13%_at_52.05%_50%,var(--error-muted)_0%,rgba(255,255,255,.5)_95%)] #{GLOW}",
    success: "relative bg-success-muted text-success-foreground outline-ring-success [a,button]:before:bg-[radial-gradient(138.15%_78.13%_at_52.05%_50%,var(--success-muted)_0%,rgba(255,255,255,.5)_95%)] #{GLOW}",
    warning: "relative bg-warning-muted text-warning-foreground outline-ring-warning [a,button]:before:bg-[radial-gradient(138.15%_78.13%_at_52.05%_50%,var(--warning-muted)_0%,rgba(255,255,255,.5)_95%)] #{GLOW}",
    info: "relative bg-info-muted text-info-foreground outline-ring-info [a,button]:before:bg-[radial-gradient(138.15%_78.13%_at_52.05%_50%,var(--info-muted)_0%,rgba(255,255,255,.5)_95%)] #{GLOW}",
    # For dark or photographic backgrounds: a translucent white fill
    light: "relative text-white before:bg-white/10 before:border-white/10 before:border before:backdrop-blur-md outline-ring-light " \
      "[a,button]:hover:before:bg-white/15 [a,button]:hover:before:border-white/15 [a,button]:data-pressed:before:bg-white/15 [a,button]:data-pressed:before:border-white/15 " \
      "[a,button]:data-popup-open:before:bg-white/15 [a,button]:data-popup-open:before:border-white/15 data-active:before:bg-white/15 data-active:before:border-white/15"
  }.freeze

  SIZES = {
    xs: "h-4 w-fit gap-0.5 px-1.5 text-[.625rem] has-data-[icon=end]:pe-1.25 has-data-[icon=start]:ps-1.25 [&_svg:not([class*='size-'])]:size-2.5 [&_svg:not([class*='stroke-'])]:stroke-2",
    sm: "h-5 w-fit gap-0.5 px-2 text-xs has-data-[icon=end]:pe-1.5 has-data-[icon=start]:ps-1.5 [&_svg:not([class*='size-'])]:size-3 [&_svg:not([class*='stroke-'])]:stroke-[1.85]",
    md: "h-6 w-fit gap-0.75 px-2.5 text-xs has-data-[icon=end]:pe-1.75 has-data-[icon=start]:ps-1.75 [&_svg:not([class*='size-'])]:size-3.5 [&_svg:not([class*='stroke-'])]:stroke-[1.75]",
    lg: "h-7 w-fit gap-1 px-3 text-sm has-data-[icon=end]:pe-2.25 has-data-[icon=start]:ps-2.25 [&_svg:not([class*='size-'])]:size-4 [&_svg:not([class*='stroke-'])]:stroke-[1.75]",
    # Square badges for a lone icon; give them an aria_label
    icon_sm: "h-5 w-5 [&_svg:not([class*='size-'])]:size-3 [&_svg:not([class*='stroke-'])]:stroke-[1.85]",
    icon_md: "h-6 w-6 [&_svg:not([class*='size-'])]:size-3.5 [&_svg:not([class*='stroke-'])]:stroke-[1.75]",
    icon_lg: "h-7 w-7 [&_svg:not([class*='size-'])]:size-4 [&_svg:not([class*='stroke-'])]:stroke-[1.75]"
  }.freeze

  prop :variant, one_of(VARIANTS, :primary), default: -> { :primary }
  prop :size,    one_of(SIZES, :md), default: -> { :md }
  prop :as,      default: -> { nil }

  def view_template(&)
    attributes = mix(badge_attributes, @attributes.except(:class))
    classes = cn(BASE, VARIANTS[@variant], SIZES[@size], override: @attributes[:class])

    case element_tag
    when :a then a(**attributes, class: classes, &)
    when :button then button(**{ type: "button" }.merge(attributes), class: classes, &)
    else span(**attributes, class: classes, &)
    end
  end

  private
    # :a with an href, else a span - unless `as:` says otherwise
    def element_tag
      (@as || (@attributes[:href] ? :a : :span)).to_sym
    end

    def badge_attributes
      # Keep the slot of a part projected onto the badge (e.g. "breadcrumb-link")
      { data: { slot: ("badge" unless @attributes.dig(:data, :slot)), variant: @variant.to_s.dasherize, size: @size.to_s.dasherize } }
    end
end
