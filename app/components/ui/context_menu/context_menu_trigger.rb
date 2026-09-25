# The area that opens the menu on right-click, long-press or Shift+F10 / the context-menu key.
# Renders a <div>; a block taking an argument receives the attributes for your own element.
class UI::ContextMenuTrigger < UI::Base
  def before_template(&content)
    @render_prop = content&.arity == 1
    super
  end

  def view_template(&)
    menu = consume(:ui_dropdown_menu, component: "ContextMenu")
    attributes = mix({
      id: menu.trigger_id, aria_controls: menu.content_id,
      data: {
        slot: "context-menu-trigger", "ui--context-menu-target": "trigger",
        action: "contextmenu->ui--context-menu#openAtPointer pointerdown->ui--context-menu#press pointerup->ui--context-menu#release " \
          "pointercancel->ui--context-menu#release pointermove->ui--context-menu#pressMove"
      }
    }, @attributes)

    if @render_prop
      yield attributes
    else
      div(**attributes, class: cn("select-none [-webkit-touch-callout:none]", @attributes[:class]), &)
    end
  end
end
