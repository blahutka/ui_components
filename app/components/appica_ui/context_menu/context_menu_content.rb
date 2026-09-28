# The context menu's popup, opened at the pointer (start-aligned, 2px away).
class AppicaUI::ContextMenuContent < AppicaUI::DropdownMenuContent
  prop :side_offset, default: -> { 2 }
end
