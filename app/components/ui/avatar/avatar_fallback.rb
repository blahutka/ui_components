# Shown until (or unless) the image loads: initials or an icon. Text renders at
# 0.4em of the avatar; an svg fills it.
#
#   AvatarFallback { "SJ" }
#   AvatarFallback(delay: 600) { "SJ" }   # wait before showing, avoids a flash on fast loads
class UI::AvatarFallback < UI::Base
  BASE = "flex size-full items-center justify-center rounded-[inherit] text-[0.4em] leading-none uppercase has-[svg]:text-[1em] group-data-[status=loaded]/avatar:hidden"

  def initialize(delay: nil, **attributes)
    @delay = delay
    @attributes = attributes
  end

  def view_template(&)
    span(**mix({
      hidden: (true if @delay),
      data: { slot: "avatar-fallback", "ui--avatar-target": "fallback", delay: @delay }
    }, @attributes.except(:class)), class: cn(BASE, override: @attributes[:class]), &)
  end
end
