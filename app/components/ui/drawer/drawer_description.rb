# A <p> that describes the panel (the dialog's aria-describedby)
class UI::DrawerDescription < UI::Base
  def initialize(**attributes)
    @attributes = attributes
  end

  def view_template(&)
    p(**mix({ id: drawer.description_id, data: { slot: "drawer-description" } }, @attributes.except(:class)),
      class: cn("text-foreground-muted text-sm", override: @attributes[:class]), &)
  end

  private
    def drawer = consume(:ui_drawer, component: "Drawer")
end
