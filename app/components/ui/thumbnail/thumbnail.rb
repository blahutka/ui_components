# A compact preview tile beside a file, a list row or a media item: an image cropped to fill
# (falling back to a placeholder icon while it loads or when it fails), or a colored tile
# framing an icon.
#
#   Thumbnail(src: "/photos/summit.jpg", alt: "Mountain peak", size: :xl)
#   Thumbnail(variant: :icon_primary) { Icon(:bolt) }
#   Thumbnail(size: 56, shape: :circle, src: cover.url)
#
# Sized in em from one `size:` (a preset or pixels), so the tile and its icon scale together.
# The image variant reuses Avatar's loader (`ui--avatar`), which emits
# `ui--avatar:loading-status-change` with { status }.
class UI::Thumbnail < UI::Base
  SIZES = { "2xs": "text-[1.25rem]", xs: "text-[1.5rem]", sm: "text-[2rem]", md: "text-[2.5rem]", lg: "text-[3rem]", xl: "text-[4rem]", "2xl": "text-[5rem]" }.freeze

  VARIANTS = {
    image: "bg-background-muted",
    icon_soft: "bg-background-muted text-foreground-intense",
    icon_outline: "bg-background text-foreground-intense border border-border",
    icon_primary: "bg-primary text-primary-foreground",
    icon_primary_outline: "text-primary border border-primary",
    icon_secondary: "bg-secondary-muted text-secondary-foreground",
    icon_error: "bg-error-muted text-error-foreground",
    icon_success: "bg-success-muted text-success-foreground",
    icon_warning: "bg-warning-muted text-warning-foreground",
    icon_info: "bg-info-muted text-info-foreground"
  }.freeze

  SHAPES = { rounded: "rounded-[calc(tan(atan2(var(--radius-md),2.5rem))*100%)]", circle: "rounded-full" }.freeze

  BASE = "group/thumbnail relative inline-flex size-[1em] shrink-0 items-center justify-center overflow-hidden [&_svg:not([class*='size-'])]:size-[0.5em]"

  # Appica's placeholder: a crossed-out picture
  FALLBACK_ICON = "M2.47 2.47a.75.75 0 0 1 1.061 0l.703.703c.078.037.151.086.215.151.057.059.099.126.133.196l15.925 15.925c.057.032.113.069.162.117s.094.111.128.173l.734.734a.75.75 0 0 1-1.061 1.061l-.402-.402c-.194.128-.398.24-.613.33a3.74 3.74 0 0 1-1.454.291v.001H6A3.75 3.75 0 0 1 2.25 18V6c0-.765.23-1.476.622-2.068L2.47 3.53a.75.75 0 0 1 0-1.061zM20.25 17v-.689l-2.77-2.771c-.388-.374-.762-.485-1.079-.455a.75.75 0 0 1-.141-1.494c.727-.068 1.421.175 2.013.651l.248.218 1.73 1.729V6A2.25 2.25 0 0 0 18 3.75H7a.75.75 0 1 1 0-1.5h11A3.75 3.75 0 0 1 21.75 6v11a.75.75 0 1 1-1.5 0zm-5.24-9.75a.75.75 0 1 1 0 1.5H15a.75.75 0 1 1 0-1.5h.01zM3.75 18A2.25 2.25 0 0 0 6 20.25h12.001c.299 0 .596-.059.872-.175.033-.014.063-.032.095-.047L10.48 11.54c-.351-.338-.69-.46-.979-.46s-.628.122-.979.46L3.75 16.311V18zm0-3.81l3.729-3.729c.354-.34.753-.594 1.181-.739L3.971 5.031A2.24 2.24 0 0 0 3.75 6v8.19z"

  prop :variant, one_of(VARIANTS, :image), default: -> { :image }
  prop :size,    ->(value) { value.is_a?(Numeric) ? value : value&.to_sym }, default: -> { :md }
  prop :shape,   one_of(SHAPES, :rounded), default: -> { :rounded }
  prop :src,     default: -> { nil }
  prop :alt,     default: -> { "" }

  def view_template(&)
    div(**mix(defaults(
      data: { slot: "thumbnail", variant: @variant, controller: ("ui--avatar" if image?) },
      style: ("font-size: #{@size}px" if @size.is_a?(Numeric))
    ), @attributes.except(:class)), class: cn(BASE, SIZES[@size], SHAPES[@shape], VARIANTS[@variant], override: @attributes[:class])) do
      if image?
        img(src: @src, alt: @alt, class: "hidden size-full rounded-[inherit] object-cover group-data-[status=loaded]/thumbnail:block",
          data: { slot: "thumbnail-image", "ui--avatar-target": "image", action: "load->ui--avatar#loaded error->ui--avatar#failed" }) if @src
        span(class: "text-foreground-subtle flex size-full items-center justify-center has-[svg]:text-[1em] group-data-[status=loaded]/thumbnail:hidden",
          data: { slot: "thumbnail-fallback", "ui--avatar-target": "fallback" }) do
          svg(xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", fill: "currentColor", aria_hidden: "true", data: { slot: "thumbnail-fallback-icon" }) { |s| s.path(d: FALLBACK_ICON) }
        end
      else
        yield if block_given?
      end
    end
  end

  private
    def image? = @variant == :image
end
