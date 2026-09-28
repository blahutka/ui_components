# The element the tooltip describes. A block taking an argument receives its attributes for your
# own control (a Button, a ToolbarButton…); otherwise it renders a <span> around the content.
class AppicaUI::TooltipTrigger < AppicaUI::Base
  def before_template(&content)
    @render_prop = content&.arity == 1
    super
  end

  def view_template(&)
    tooltip = consume(:ui_popover, component: "Tooltip")
    attributes = mix({
      aria_describedby: tooltip.popup_id,
      data: {
        slot: "tooltip-trigger", "appica-ui--popover-target": "trigger", delay: tooltip.trigger_delay, close_delay: tooltip.trigger_close_delay,
        action: "pointerenter->appica-ui--popover#pointerEnter pointerleave->appica-ui--popover#pointerLeave pointermove->appica-ui--popover#pointerMove " \
          "focusin->appica-ui--popover#focusIn focusout->appica-ui--popover#focusOut click->appica-ui--popover#toggle"
      }
    }, @attributes)
    @render_prop ? yield(attributes) : span(**attributes, &)
  end
end
