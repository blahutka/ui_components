# A crumb: an <a>, or with `active: true` the current page - a non-interactive <span> with
# aria-current="page". `disabled: true` dims it and takes it out of the tab order.
# A block taking an argument receives the attributes for your own element (Appica's `render`):
#
#   BreadcrumbLink(href: "/") { "Home" }
#   BreadcrumbLink(href: "/", class: "…") { |crumb| Badge(**crumb, variant: :soft) { "Home" } }
class UI::BreadcrumbLink < UI::Base
  BASE = "inline-flex items-center gap-1.5 outline-ring transition duration-250 motion-reduce:transition-none"
  LINK = "hover:text-foreground-intense ease-[cubic-bezier(0.175,0.885,0.32,1.5)] active:scale-[0.97] active:duration-100 active:ease-in-out active:translate-y-px"
  CURRENT = "text-foreground-intense pointer-events-none"
  DISABLED = "opacity-disabled pointer-events-none"

  prop :active,   default: -> { false }
  prop :disabled, default: -> { false }

  def before_template(&content)
    @render_prop = content&.arity == 1
    super
  end

  def view_template(&)
    attributes = mix(link_attributes, @attributes.except(:class))

    if @render_prop
      yield attributes.merge(class: @attributes[:class]).compact
    elsif @active || @disabled
      span(**attributes.except(:href), class: classes, &)
    else
      a(**attributes, class: classes, &)
    end
  end

  private
    def link_attributes
      if @active
        { aria_current: "page", aria_disabled: "true", tabindex: "-1", data: { slot: "breadcrumb-link", active: "true", disabled: "" } }
      elsif @disabled
        { aria_disabled: "true", tabindex: "-1", data: { slot: "breadcrumb-link", disabled: "" } }
      else
        { data: { slot: "breadcrumb-link" } }
      end
    end

    def classes
      cn(BASE, (@active ? CURRENT : (@disabled ? DISABLED : LINK)), override: @attributes[:class])
    end
end
