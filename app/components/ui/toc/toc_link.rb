# A link to one heading (`href: "#id"`); `depth:` (2-6, the heading level) indents it.
# A block taking an argument receives the attributes for your own element.
class UI::TocLink < UI::Base
  LINK = "text-foreground-muted block transform-gpu py-1.5 text-sm font-medium outline-none transition duration-250 motion-reduce:transition-none " \
    "hover:text-foreground-intense focus-visible:text-foreground-intense data-active:text-foreground-intense " \
    "active:scale-[0.98] active:translate-y-px active:duration-100 active:ease-in-out " \
    "[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='stroke-'])]:stroke-[1.85] [&_svg:not([class*='size-'])]:size-4.5"
  DEPTHS = { 2 => "ps-4", 3 => "ps-7", 4 => "ps-10", 5 => "ps-13", 6 => "ps-16" }.freeze

  prop :href
  prop :depth, ->(value) { value.to_i.clamp(2, 6) }, default: -> { 2 }

  def before_template(&content)
    @render_prop = content&.arity == 1
    super
  end

  def view_template(&)
    attributes = mix({ href: @href, data: { slot: "toc-link", depth: @depth, "ui--toc-target": "link" } }, @attributes.except(:class))
      .merge(class: cn(LINK, DEPTHS[@depth], override: @attributes[:class]))

    if @render_prop
      yield attributes
    else
      a(**attributes, &)
    end
  end
end
