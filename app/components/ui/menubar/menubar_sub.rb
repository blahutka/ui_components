# A nested submenu: MenubarSubTrigger plus MenubarSubContent
class UI::MenubarSub < UI::Base
  attr_reader :id

  def initialize(**attributes)
    @attributes = attributes
    @id = attributes.delete(:id) || "menubar-sub-#{SecureRandom.hex(4)}"
  end

  def view_template(&)
    provide(:ui_menubar_sub, self) do
      div(**mix({ id:, data: { slot: "menubar-sub" } }, @attributes.except(:class)), class: cn("relative flex flex-col", override: @attributes[:class]), &)
    end
  end

  def trigger_id = "#{id}-trigger"
  def content_id = "#{id}-content"
end
