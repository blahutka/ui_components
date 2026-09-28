# A section that expands and collapses to show or hide its content.
#
#   Collapsible(open: true) do
#     CollapsibleTrigger { "What's included in the free plan?" }
#     CollapsibleContent { p { "Up to three projects, 1 GB of storage, and community support." } }
#   end
#
# One trigger, one panel; for a set of mutually-aware sections use an Accordion. The parts
# ship almost unstyled. State is rendered on the server (data-open / data-closed on the root,
# data-panel-open on the trigger) and the `appica-ui--collapsible` controller toggles and animates it.
class AppicaUI::Collapsible < AppicaUI::Base
  prop :open,         default: -> { false }
  prop :default_open, default: -> { nil }
  prop :disabled,     default: -> { false }
  prop :id,           default: -> { "collapsible-#{SecureRandom.hex(4)}" }

  attr_reader :id

  def view_template(&)
    provide(:ui_collapsible, self) do
      div(**mix({
        id:,
        data: {
          slot: "collapsible",
          open: (open? ? "" : nil),
          closed: (open? ? nil : ""),
          disabled: (disabled? ? "" : nil),
          controller: "appica-ui--collapsible",
          "appica-ui--collapsible-open-value": open?.to_s,
          "appica-ui--collapsible-disabled-value": disabled?.to_s
        }
      }, @attributes.except(:class)), class: cn(nil, override: @attributes[:class]), &)
    end
  end

  def open? = @default_open.nil? ? @open : @default_open
  def disabled? = @disabled
  def content_id = "#{id}-content"
end
