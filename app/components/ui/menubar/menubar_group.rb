# One labelled section of a menu; give it a MenubarGroupLabel
class UI::MenubarGroup < UI::Base
  def label_id
    @label_id ||= "menubar-group-#{SecureRandom.hex(4)}"
  end

  def view_template(&)
    provide(:ui_menubar_group, self) do
      div(**mix({ role: "group", aria: { labelledby: label_id }, data: { slot: "menubar-group" } }, @attributes.except(:class)),
          class: cn("flex flex-col gap-0.5", override: @attributes[:class]), &)
    end
  end
end
