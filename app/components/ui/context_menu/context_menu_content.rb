# The context menu's popup, opened at the pointer (start-aligned, 2px away).
class UI::ContextMenuContent < UI::DropdownMenuContent
  prop :side_offset, default: -> { 2 }
end
