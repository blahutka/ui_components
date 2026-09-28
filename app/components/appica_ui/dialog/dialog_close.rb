# A button that closes the dialog. A block taking an argument receives its attributes for your
# own Button: `DialogClose { |close| Button(**close) { "Done" } }`. It's `type="button"`, so a
# form's submit button should be a plain Button with type: "submit" (the dialog closes when
# the page navigates or a Turbo Stream replaces it).
class AppicaUI::DialogClose < AppicaUI::Base
  def before_template(&content)
    @render_prop = content&.arity == 1
    super
  end

  def view_template(&)
    dialog = consume(:ui_dialog, component: "Dialog")
    attributes = mix({ type: "button", data: { slot: "#{dialog.slot}-close", action: "#{dialog.identifier}#close" } }, @attributes)

    if @render_prop
      yield attributes
    else
      button(**attributes, &)
    end
  end
end
