# The photo. Hidden until it has loaded, so a slow or broken image never flashes;
# the controller then swaps it in for the AvatarFallback.
class UI::AvatarImage < UI::Base
  prop :src, default: -> { nil }
  prop :alt, default: -> { "" }

  def view_template
    img(**mix({
      src: @src,
      alt: @alt,
      data: {
        slot: "avatar-image",
        "ui--avatar-target": "image",
        action: "load->ui--avatar#loaded error->ui--avatar#failed"
      }
    }, @attributes.except(:class)), class: cn("hidden size-full rounded-[inherit] object-cover group-data-[status=loaded]/avatar:block", override: @attributes[:class]))
  end
end
