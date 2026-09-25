# A rich preview of a link, shown while it's hovered or focused - the profile behind an
# @mention, the cover behind an article link.
#
#   PreviewCard do
#     PreviewCardTrigger(href: "https://appica.dev") { "@appica_ui" }
#     PreviewCardContent { p { "Appica UI" } }
#   end
#
# The trigger stays a real link. The card opens after `delay:` (600 ms) on hover or keyboard focus
# and closes `close_delay:` (300 ms) after the pointer leaves the link and the card. It's
# invisible on touch and to screen readers - keep it supplementary.
class UI::PreviewCard < UI::Popover
  prop :delay,       default: -> { 600 }
  prop :close_delay, default: -> { 300 }
  prop :id,          default: -> { "preview-card-#{SecureRandom.hex(4)}" }

  def slot = "preview-card"

  def view_template(&)
    provide(:ui_popover, self) do
      span(**mix(defaults(id: @id, data: {
        slot:, controller: "ui--popover", "ui--popover-open-value": @default_open.to_s,
        "ui--popover-hover-value": "true", "ui--popover-focus-value": "true",
        "ui--popover-delay-value": @delay, "ui--popover-close-delay-value": @close_delay
      }), @attributes.except(:class)), class: cn("inline-flex w-fit", override: @attributes[:class]), &)
    end
  end
end
