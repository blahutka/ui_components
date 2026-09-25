# A focused task or content that interrupts the page, in a centered modal.
#
#   Dialog do
#     DialogTrigger { |trigger| Button(**trigger, variant: :outline) { "Invite people" } }
#     DialogContent do
#       DialogHeader do
#         DialogTitle { "Invite your team" }
#         DialogDescription { "Send an invitation by email." }
#       end
#       DialogBody { … }
#       DialogFooter do
#         DialogClose { |close| Button(**close, variant: :outline) { "Cancel" } }
#         DialogClose { |close| Button(**close) { "Send invites" } }
#       end
#     end
#   end
#
# DialogContent is a native <dialog> opened with showModal(): top layer, focus trapped, the
# page behind inert, Escape to close, focus returned to the trigger. A click outside closes it
# unless `dismissible: false`; `modal: false` leaves the page usable. `default_open: true`
# renders it open (e.g. a dialog streamed in by Turbo). A Dialog inside another's content
# stacks on top and the parent steps back. Emits `ui--dialog:open-change` with { open }; dispatch
# `ui--dialog:open` / `ui--dialog:close` on the root to drive it.
class UI::Dialog < UI::Base
  prop :default_open, default: -> { false }
  prop :modal,        default: -> { true }
  prop :dismissible,  default: -> { true }
  prop :id,           default: -> { "#{self.class.name.demodulize.underscore.dasherize}-#{SecureRandom.hex(4)}" }

  attr_reader :id

  # The Stimulus controller and data-slot prefix of the parts (AlertDialog reuses them)
  def identifier = "ui--dialog"
  def slot = "dialog"
  def role = "dialog"

  def trigger_id = "#{@id}-trigger"
  def popup_id = "#{@id}-popup"
  def title_id = "#{@id}-title"
  def description_id = "#{@id}-description"

  def view_template(&)
    provide(:ui_dialog, self) do
      div(**mix(defaults(
        id: @id,
        data: {
          slot:, controller: identifier,
          "#{identifier}-open-value": @default_open.to_s, "#{identifier}-modal-value": @modal.to_s, "#{identifier}-dismissible-value": @dismissible.to_s,
          action: "#{identifier}:open->#{identifier}#open #{identifier}:close->#{identifier}#close"
        }
      ), @attributes.except(:class)), class: cn("contents", override: @attributes[:class]), &)
    end
  end
end
