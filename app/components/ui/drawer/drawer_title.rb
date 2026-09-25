# An <h2> that labels the panel (the dialog's aria-labelledby)
class UI::DrawerTitle < UI::Base
  def view_template(&)
    h2(**mix({ id: drawer.title_id, data: { slot: "drawer-title" } }, @attributes.except(:class)),
       class: cn("text-foreground-intense text-2xl font-semibold", override: @attributes[:class]), &)
  end

  private
    def drawer = consume(:ui_drawer, component: "Drawer")
end
