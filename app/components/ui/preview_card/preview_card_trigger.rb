# The link that shows the preview - an <a> with `href:` (style it like any link in your prose).
# A block taking an argument receives the attributes for your own link (a `link_to`).
class UI::PreviewCardTrigger < UI::Base
  def before_template(&content)
    @render_prop = content&.arity == 1
    super
  end

  def view_template(&)
    card = consume(:ui_popover, component: "PreviewCard")
    attributes = mix({
      aria_describedby: card.popup_id,
      data: {
        slot: "preview-card-trigger", "ui--popover-target": "trigger",
        action: "pointerenter->ui--popover#pointerEnter pointerleave->ui--popover#pointerLeave focusin->ui--popover#focusIn focusout->ui--popover#focusOut"
      }
    }, @attributes)
    @render_prop ? yield(attributes) : a(**attributes, &)
  end
end
