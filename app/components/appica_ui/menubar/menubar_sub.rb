# A nested submenu: MenubarSubTrigger plus MenubarSubContent
class AppicaUI::MenubarSub < AppicaUI::Base
  prop :id, default: -> { "menubar-sub-#{SecureRandom.hex(4)}" }

  attr_reader :id

  def view_template(&)
    provide(:ui_menubar_sub, self) do
      div(**mix({ id:, data: { slot: "menubar-sub" } }, @attributes.except(:class)), class: cn("relative flex flex-col", override: @attributes[:class]), &)
    end
  end

  def trigger_id = "#{id}-trigger"
  def content_id = "#{id}-content"
end
