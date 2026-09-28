# The <h2> that labels the dialog.
class AppicaUI::DialogTitle < AppicaUI::Base
  def view_template(&)
    dialog = consume(:ui_dialog, component: "Dialog")
    h2(**mix({ id: dialog.title_id, data: { slot: "#{dialog.slot}-title" } }, @attributes.except(:class)),
      class: cn("text-foreground-intense font-semibold", title_size, override: @attributes[:class]), &)
  end

  private
    def title_size = "text-2xl"
end
