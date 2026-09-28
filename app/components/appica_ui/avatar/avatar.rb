# A user image with a text or icon fallback when it's missing.
#
#   Avatar(size: :lg) do
#     AvatarImage(src: user.avatar_url, alt: user.name)
#     AvatarFallback { user.initials }
#     AvatarBadge(animate: true)
#   end
#
# Sized in em: `size:` sets the root's font-size, so the image, fallback text and
# badge scale together. The `appica-ui--avatar` controller shows the image once it has
# loaded and keeps the fallback when it's missing or fails.
class AppicaUI::Avatar < AppicaUI::Base
  BASE = "group/avatar relative flex size-[1em] shrink-0 items-center justify-center bg-background-strong text-center font-medium text-foreground-emphasis [&_svg:not([class*='size-'])]:size-[0.5em]"

  SIZES = {
    "2xs": "text-[1.25rem]",
    xs: "text-[1.5rem]",
    sm: "text-[2rem]",
    md: "text-[2.5rem]",
    lg: "text-[3rem]",
    xl: "text-[4rem]",
    "2xl": "text-[5rem]"
  }.freeze

  SHAPES = {
    circle: "rounded-full",
    # A squircle: the md radius relative to the avatar size, so it scales with it
    rounded: "rounded-[calc(tan(atan2(var(--radius-md),2.5rem))*100%)]"
  }.freeze

  prop :size,  default: -> { nil }
  prop :shape, default: -> { nil }

  def view_template(&)
    span(**mix(root_attributes, @attributes.except(:class)), class: cn(BASE, size_class, SHAPES.fetch(shape, SHAPES[:circle]), override: @attributes[:class]), &)
  end

  private
    # A child's own size/shape wins over the AvatarGroup default
    def size = @size || group&.size || :md
    def shape = (@shape || group&.shape || :circle).to_sym
    def group = context[:ui_avatar_group]

    def size_class
      SIZES.fetch(size.to_s.to_sym, SIZES[:md]) unless size.is_a?(Numeric)
    end

    def root_attributes
      {
        style: ("font-size: #{size}px" if size.is_a?(Numeric)),
        data: { slot: "avatar", controller: "appica-ui--avatar", status: "idle" }
      }
    end
end
