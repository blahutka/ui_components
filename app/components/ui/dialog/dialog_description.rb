# The <p> that describes the dialog.
class UI::DialogDescription < UI::Base
  def view_template(&)
    dialog = consume(:ui_dialog, component: "Dialog")
    p(**mix({ id: dialog.description_id, data: { slot: "#{dialog.slot}-description" } }, @attributes.except(:class)),
      class: cn("text-foreground-muted text-sm", override: @attributes[:class]), &)
  end
end
