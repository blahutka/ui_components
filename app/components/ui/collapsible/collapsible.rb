# A section that expands and collapses to show or hide its content.
#
#   Collapsible(open: true) do
#     CollapsibleTrigger { "What's included in the free plan?" }
#     CollapsibleContent { p { "Up to three projects, 1 GB of storage, and community support." } }
#   end
#
# One trigger, one panel; for a set of mutually-aware sections use an Accordion. The parts
# ship almost unstyled. State is rendered on the server (data-open / data-closed on the root,
# data-panel-open on the trigger) and the `ui--collapsible` controller toggles and animates it.
class UI::Collapsible < UI::Base
  attr_reader :id

  def initialize(open: false, default_open: nil, disabled: false, **attributes)
    @open = default_open.nil? ? open : default_open
    @disabled = disabled
    @attributes = attributes
    @id = attributes.delete(:id) || "collapsible-#{SecureRandom.hex(4)}"
  end

  def view_template(&)
    provide(:ui_collapsible, self) do
      div(**mix({
        id:,
        data: {
          slot: "collapsible",
          open: (open? ? "" : nil),
          closed: (open? ? nil : ""),
          disabled: (disabled? ? "" : nil),
          controller: "ui--collapsible",
          "ui--collapsible-open-value": open?.to_s,
          "ui--collapsible-disabled-value": disabled?.to_s
        }
      }, @attributes.except(:class)), class: cn(nil, override: @attributes[:class]), &)
    end
  end

  def open? = @open
  def disabled? = @disabled
  def content_id = "#{id}-content"
end
