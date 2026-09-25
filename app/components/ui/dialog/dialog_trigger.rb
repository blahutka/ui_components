# The button that opens the dialog. A block taking an argument receives its attributes for your
# own element: `DialogTrigger { |trigger| Button(**trigger) { "Open" } }`.
class UI::DialogTrigger < UI::Base
  def before_template(&content)
    @render_prop = content&.arity == 1
    super
  end

  def view_template(&)
    dialog = consume(:ui_dialog, component: "Dialog")
    attributes = mix({
      type: "button", id: dialog.trigger_id, aria_haspopup: "dialog", aria_expanded: "false", aria_controls: dialog.popup_id,
      data: { slot: "#{dialog.slot}-trigger", "#{dialog.identifier}-target": "trigger", action: "#{dialog.identifier}#open" }
    }, @attributes)

    if @render_prop
      yield attributes
    else
      button(**attributes, &)
    end
  end
end
