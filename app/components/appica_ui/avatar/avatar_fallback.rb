# Shown until (or unless) the image loads: initials or an icon. Text renders at
# 0.4em of the avatar; an svg fills it.
#
#   AvatarFallback { "SJ" }
#   AvatarFallback(delay: 600) { "SJ" }   # wait before showing, avoids a flash on fast loads
class AppicaUI::AvatarFallback < AppicaUI::Base
  BASE = "flex size-full items-center justify-center rounded-[inherit] text-[0.4em] leading-none uppercase has-[svg]:text-[1em] group-data-[status=loaded]/avatar:hidden"

  prop :delay, default: -> { nil }

  def view_template(&)
    span(**mix({
      hidden: (true if @delay),
      data: { slot: "avatar-fallback", "appica-ui--avatar-target": "fallback", delay: @delay }
    }, @attributes.except(:class)), class: cn(BASE, override: @attributes[:class]), &)
  end
end
