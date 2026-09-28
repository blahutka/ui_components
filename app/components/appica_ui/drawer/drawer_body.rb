# The main content region. It owns the scroll, and swipes that start inside it
# scroll the content instead of dismissing the drawer.
class AppicaUI::DrawerBody < AppicaUI::Base
  def view_template(&)
    div(**mix({ data: { slot: "drawer-body", drawer_content: "", "appica-ui--drawer-target": "body" } }, @attributes.except(:class)),
        class: cn("min-h-0 flex-1 overflow-y-auto px-6", override: @attributes[:class]), &)
  end
end
