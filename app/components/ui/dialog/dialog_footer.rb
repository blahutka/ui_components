# The actions - stacked on small screens, a right-aligned row from `sm` up.
class UI::DialogFooter < UI::Base
  def view_template(&)
    dialog = consume(:ui_dialog, component: "Dialog")
    div(**mix({ data: { slot: "#{dialog.slot}-footer" } }, @attributes.except(:class)),
      class: cn("flex flex-col-reverse gap-2 p-6 sm:flex-row sm:justify-end", override: @attributes[:class]), &)
  end
end
