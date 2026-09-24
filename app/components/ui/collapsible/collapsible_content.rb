# The panel. It animates its height open and closed through --collapsible-panel-height.
#
# Closed panels carry the `hidden` attribute, so their text isn't searchable; with
# `hidden_until_found: true` they use `hidden="until-found"` instead, and the browser's
# find-in-page opens the panel when it finds a match inside.
class UI::CollapsibleContent < UI::Base
  BASE = "overflow-hidden h-(--collapsible-panel-height) data-ending-style:h-0 data-starting-style:h-0 " \
    "transition-[height] duration-400 ease-[cubic-bezier(0.32,0.72,0,1)] motion-reduce:transition-none"

  def initialize(hidden_until_found: false, keep_mounted: nil, **attributes)
    @hidden_until_found = hidden_until_found
    @attributes = attributes
  end

  def view_template(&)
    open = collapsible.open?

    div(**mix({
      id: collapsible.content_id,
      hidden: (open ? nil : (@hidden_until_found ? "until-found" : true)),
      style: "--collapsible-panel-height: auto",
      data: {
        slot: "collapsible-content",
        open: (open ? "" : nil),
        closed: (open ? nil : ""),
        hidden_until_found: (@hidden_until_found ? "" : nil),
        "ui--collapsible-target": "content",
        action: "beforematch->ui--collapsible#reveal"
      }
    }, @attributes.except(:class)), class: cn(BASE, override: @attributes[:class]), &)
  end

  private
    def collapsible = consume(:ui_collapsible, component: "Collapsible")
end
