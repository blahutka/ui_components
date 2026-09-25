# The actions, stacked at the bottom of the panel
class UI::DrawerFooter < UI::Base
  def view_template(&)
    div(**mix({ data: { slot: "drawer-footer" } }, @attributes.except(:class)),
        class: cn("flex flex-col gap-2 p-6", override: @attributes[:class]), &)
  end
end
