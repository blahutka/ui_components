# The button that toggles the popover. A block taking an argument receives its attributes for
# your own Button. `open_on_hover: true` also opens it on pointer rest (`delay:` / `close_delay:`).
class AppicaUI::PopoverTrigger < AppicaUI::Base
  prop :open_on_hover, default: -> { false }
  prop :delay,         default: -> { nil }
  prop :close_delay,   default: -> { nil }

  def before_template(&content)
    @render_prop = content&.arity == 1
    super
  end

  def view_template(&)
    popover = consume(:ui_popover, component: "Popover")
    attributes = mix({
      type: "button", aria_haspopup: "dialog", aria_expanded: "false", aria_controls: popover.popup_id,
      data: {
        slot: "#{popover.slot}-trigger", "appica-ui--popover-target": "trigger",
        action: "click->appica-ui--popover#toggle pointerenter->appica-ui--popover#pointerEnter pointerleave->appica-ui--popover#pointerLeave focusout->appica-ui--popover#focusOut",
        hover: (@open_on_hover.to_s if @open_on_hover), delay: @delay, close_delay: @close_delay
      }
    }, @attributes)

    if @render_prop
      yield attributes
    else
      button(**attributes, &)
    end
  end
end
