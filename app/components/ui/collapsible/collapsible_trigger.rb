# The button that toggles the panel, with aria-expanded / aria-controls wired to it.
# Exposes data-panel-open and data-disabled for styling (e.g. a chevron with
# `group-data-panel-open:rotate-90` inside a trigger that has the `group` class).
#
# A block taking an argument receives the trigger attributes to put on your own element:
#   CollapsibleTrigger { |trigger| Button(**trigger, variant: :outline, icon: true) { … } }
class UI::CollapsibleTrigger < UI::Base
  BASE = "outline-ring cursor-pointer select-none data-disabled:opacity-disabled data-disabled:pointer-events-none"

  def initialize(**attributes)
    @attributes = attributes
  end

  def before_template(&content)
    @render_prop = content&.arity == 1
    super
  end

  def view_template
    if @render_prop
      yield mix(trigger_attributes, @attributes.except(:class)).merge(class: cn(BASE, override: @attributes[:class]))
    else
      button(**mix(trigger_attributes, @attributes.except(:class)), class: cn(BASE, override: @attributes[:class])) { yield }
    end
  end

  private
    def collapsible = consume(:ui_collapsible, component: "Collapsible")

    def trigger_attributes
      {
        type: "button",
        tabindex: (collapsible.disabled? ? "-1" : nil),
        aria: { expanded: collapsible.open?.to_s, controls: collapsible.content_id, disabled: collapsible.disabled?.to_s },
        data: {
          slot: "collapsible-trigger",
          panel_open: (collapsible.open? ? "" : nil),
          disabled: (collapsible.disabled? ? "" : nil),
          "ui--collapsible-target": "trigger",
          action: "ui--collapsible#toggle"
        }
      }
    end
end
