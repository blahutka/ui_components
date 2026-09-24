# Wraps one menu in the bar: a trigger and its popup
class UI::MenubarMenu < UI::Base
  attr_reader :id

  def initialize(disabled: false, **attributes)
    @disabled = disabled
    @attributes = attributes
    @id = attributes.delete(:id) || "menubar-menu-#{SecureRandom.hex(4)}"
  end

  def view_template(&)
    provide(:ui_menubar_menu, self) do
      div(**mix({ id:, data: { slot: "menubar-menu", disabled: (@disabled ? "" : nil), "ui--menubar-target": "menu" } }, @attributes.except(:class)),
          class: cn("relative flex", ("flex-col" if context[:ui_menubar]&.vertical?), override: @attributes[:class]), &)
    end
  end

  def disabled? = @disabled || context[:ui_menubar]&.disabled?
  def trigger_id = "#{id}-trigger"
  def content_id = "#{id}-content"
end
