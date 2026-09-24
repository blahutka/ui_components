# A thin divider between items or groups
class UI::MenubarSeparator < UI::Base
  def initialize(**attributes)
    @attributes = attributes
  end

  def view_template
    div(**mix({ role: "separator", aria: { orientation: "horizontal" }, data: { slot: "menubar-separator" } }, @attributes.except(:class)),
        class: cn("bg-border -mx-2 my-1.5 h-px shrink-0", override: @attributes[:class]))
  end
end
