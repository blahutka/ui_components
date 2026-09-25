# Groups the title and description with consistent spacing
class UI::DrawerHeader < UI::Base
  def view_template(&)
    div(**mix({ data: { slot: "drawer-header" } }, @attributes.except(:class)),
        class: cn("flex shrink-0 flex-col gap-2 p-6", override: @attributes[:class]), &)
  end
end
