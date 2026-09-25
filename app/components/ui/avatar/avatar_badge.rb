# A status dot in the corner. Recolor it with a text-* class; `animate: true`
# adds a pulsing ping (skipped when the user prefers reduced motion).
class UI::AvatarBadge < UI::Base
  BASE = "bg-background text-success-emphasis absolute inset-e-0 bottom-0 z-1 flex size-[30%] items-center justify-center rounded-full"

  prop :animate, default: -> { false }

  def view_template
    span(**mix({ data: { slot: "avatar-badge" } }, @attributes.except(:class)), class: cn(BASE, override: @attributes[:class])) do
      span(class: "size-[66%] rounded-full bg-current")
      span(class: "animate-ping-paced absolute h-full w-full rounded-full bg-current opacity-50 motion-reduce:hidden") if @animate
    end
  end
end
