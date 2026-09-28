# Rich, interactive content floating beside a control - a form, settings, a share sheet.
#
#   Popover do
#     PopoverTrigger { |trigger| Button(**trigger, variant: :outline) { "Share" } }
#     PopoverContent do
#       PopoverTitle { "Share this page" }
#       PopoverDescription { "Anyone with the link can view this document." }
#     end
#   end
#
# The popup opens in the top layer on click (or on hover with `open_on_hover: true` on the
# trigger), placed by `side:` / `align:` on PopoverContent with an arrow, flipping to stay in view.
# Escape, a click outside or a PopoverClose dismiss it. Emits `appica-ui--popover:open-change`.
class AppicaUI::Popover < AppicaUI::Base
  prop :default_open, default: -> { false }
  prop :id,           default: -> { "popover-#{SecureRandom.hex(4)}" }

  attr_reader :id

  def slot = "popover"
  def popup_id = "#{@id}-popup"
  def title_id = "#{@id}-title"
  def description_id = "#{@id}-description"

  def view_template(&)
    provide(:ui_popover, self) do
      div(**mix(defaults(id: @id, data: { slot:, controller: "appica-ui--popover", "appica-ui--popover-open-value": @default_open.to_s, "appica-ui--popover-click-value": "true" }),
        @attributes.except(:class)), class: cn("inline-flex w-fit", override: @attributes[:class]), &)
    end
  end
end
