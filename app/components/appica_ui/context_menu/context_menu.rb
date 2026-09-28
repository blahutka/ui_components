# A menu of actions for an object, opened by right-clicking (or long-pressing) it.
#
#   ContextMenu do
#     ContextMenuTrigger(class: "flex h-40 w-72 items-center justify-center rounded-xl border border-dashed") { "Right-click here" }
#     ContextMenuContent do
#       ContextMenuItem { "Copy" }
#       ContextMenuSeparator()
#       ContextMenuItem { "Delete" }
#     end
#   end
#
# The parts are DropdownMenu's (items, checkbox / radio items, groups, submenus, keyboard); the
# popup opens at the pointer. Emits the same events under `appica-ui--context-menu:`.
class AppicaUI::ContextMenu < AppicaUI::DropdownMenu
  def identifier = "appica-ui--context-menu"
  def slot = "context-menu"

  def view_template(&)
    provide(:ui_dropdown_menu, self) do
      div(**mix(defaults(id: @id, data: root_data), @attributes.except(:class)), class: cn("contents", override: @attributes[:class]), &)
    end
  end
end
