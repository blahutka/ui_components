# The visible heading of a MenubarGroup or MenubarRadioGroup
class AppicaUI::MenubarGroupLabel < AppicaUI::Base
  def view_template(&)
    div(**mix({ id: context[:ui_menubar_group]&.label_id, aria_hidden: "true", data: { slot: "menubar-group-label" } }, @attributes.except(:class)),
        class: cn("text-foreground-subtle", bar.label_classes, override: @attributes[:class]), &)
  end

  private
    def bar = consume(:ui_menubar, component: "Menubar")
end
