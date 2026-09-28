# The button that toggles the menu. A block taking an argument receives its attributes for your
# own element (Appica's `render` prop): `DropdownMenuTrigger { |t| Button(**t) { "Open" } }`.
class AppicaUI::DropdownMenuTrigger < AppicaUI::Base
  prop :disabled, default: -> { false }

  def before_template(&content)
    @render_prop = content&.arity == 1
    super
  end

  def view_template(&)
    menu = consume(:ui_dropdown_menu, component: "DropdownMenu")
    attributes = mix({
      type: "button", id: menu.trigger_id, aria_haspopup: "menu", aria_expanded: "false", aria_controls: menu.content_id,
      disabled: (true if @disabled),
      data: { slot: "#{menu.slot}-trigger", "#{menu.identifier}-target": "trigger", action: "#{menu.identifier}#toggle" }
    }, @attributes)

    if @render_prop
      yield attributes
    else
      button(**attributes, &)
    end
  end
end
