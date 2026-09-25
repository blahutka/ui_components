# A placeholder block shown while content loads. It has no size of its own - shape it with
# utility classes (h-* / w-* / size-*, rounded-*):
#
#   Skeleton(class: "h-4 w-40")
#   Skeleton(class: "size-10 rounded-full")
#   Skeleton(effect: :pulse, class: "text-primary aspect-video w-full rounded-lg")
#
# The surface and the shimmer both come from currentColor, so one text-* class recolors it;
# `--skeleton-highlight` sets the shimmer on its own. `effect:` is :shimmer (a highlight gliding
# across), :pulse or :none; both animations stop under prefers-reduced-motion. Decorative
# (aria-hidden) - mark the loading region aria-busy instead.
class UI::Skeleton < UI::Base
  BASE = "text-foreground-muted relative block shrink-0 overflow-hidden bg-current/10 backdrop-blur-xl rounded-md"
  EFFECTS = { shimmer: "skeleton-shimmer", pulse: "motion-safe:animate-pulse", none: "" }.freeze

  prop :effect, one_of(EFFECTS, :shimmer), default: -> { :shimmer }

  def view_template
    div(**mix({ aria_hidden: "true", data: { slot: "skeleton", effect: @effect } }, @attributes.except(:class)),
      class: cn(BASE, EFFECTS[@effect], override: @attributes[:class]))
  end
end
