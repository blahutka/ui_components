# Groups the title and description.
class AppicaUI::DialogHeader < AppicaUI::Base
  def view_template(&)
    dialog = consume(:ui_dialog, component: "Dialog")
    div(**mix({ data: { slot: "#{dialog.slot}-header" } }, @attributes.except(:class)), class: cn("flex shrink-0 flex-col gap-2 p-6", override: @attributes[:class]), &)
  end
end
