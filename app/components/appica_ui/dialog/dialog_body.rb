# The dialog's main content. Give the content a fixed height and a scrolling body for long text.
class AppicaUI::DialogBody < AppicaUI::Base
  def view_template(&)
    dialog = consume(:ui_dialog, component: "Dialog")
    div(**mix({ data: { slot: "#{dialog.slot}-body" } }, @attributes.except(:class)), class: cn("min-h-0 flex-1 px-6", override: @attributes[:class]), &)
  end
end
