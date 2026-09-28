# A menu of actions for an object, opened by right-clicking (or long-pressing) it.
#
# @label Context Menu
# @logical_path Menus
# @component AppicaUI::ContextMenu
# @display width wide
# @display min_height 380px
class AppicaUI::ContextMenuPreview < AppicaUI::BasePreview
  # Props not in the Usage form (data, render blocks, generated ids): see ui_components:preview_params
  UNLISTED_PROPS = %i[ id ].freeze

  AREA = "border-border-strong text-foreground-muted flex h-40 w-72 max-w-full items-center justify-center rounded-xl border border-dashed text-sm"

  # @label Basic
  # Right-click the area (long-press on touch, Shift+F10 when focused).
  # @param size [Symbol] select {{ choices_for AppicaUI::ContextMenu, :size }}
  # @param open_on_hover [Boolean] toggle
  # @param delay number
  # @param close_delay number
  def default(size: :md, open_on_hover: false, delay: 100, close_delay: 100)
    phlex do
      ContextMenu(size:, open_on_hover:, delay:, close_delay:) do
        ContextMenuTrigger(class: AREA, tabindex: "0") { "Right-click here" }
        ContextMenuContent do
          ContextMenuGroup do
            ContextMenuGroupLabel { "Edit" }
            { copy: [ "Copy", "⌘C" ], scissors: [ "Cut", "⌘X" ], clipboard: [ "Paste", "⌘V" ] }.each do |icon, (label, keys)|
              ContextMenuItem { Icon(icon, data: { icon: "start" }); plain label; Kbd(size: :sm, class: "ms-auto") { keys } }
            end
          end
          ContextMenuSeparator()
          ContextMenuItem(class: "text-error-emphasis") { Icon(:trash, data: { icon: "start" }); plain "Delete" }
        end
      end
    end
  end

  # @label On a card
  # The trigger wraps any content - here a file card with a "Move to" submenu.
  def card
    phlex do
      ContextMenu do
        ContextMenuTrigger(tabindex: "0", class: "border-border bg-background flex w-72 max-w-full items-center gap-3 rounded-xl border p-4 outline-ring") do
          span(class: "bg-background-muted text-foreground-muted flex size-10 items-center justify-center rounded-lg") { Icon(:file) }
          span(class: "flex min-w-0 flex-col") do
            span(class: "text-foreground-intense truncate text-sm font-medium") { "Q3-roadmap.pdf" }
            span(class: "text-foreground-muted text-xs") { "2.4 MB · Edited yesterday" }
          end
        end
        ContextMenuContent do
          ContextMenuItem { Icon(:external_link, data: { icon: "start" }); plain "Open" }
          ContextMenuItem { Icon(:pencil, data: { icon: "start" }); plain "Rename" }
          ContextMenuItem { Icon(:share, data: { icon: "start" }); plain "Share" }
          ContextMenuSub do
            ContextMenuSubTrigger { Icon(:folder, data: { icon: "start" }); plain "Move to" }
            ContextMenuSubContent do
              %w[ Documents Projects Archive ].each { |folder| ContextMenuItem { folder } }
            end
          end
          ContextMenuSeparator()
          ContextMenuItem(class: "text-error-emphasis") { Icon(:trash, data: { icon: "start" }); plain "Delete" }
        end
      end
    end
  end

  # @label Checkbox & radio items
  def stateful
    phlex do
      ContextMenu do
        ContextMenuTrigger(class: AREA, tabindex: "0") { "Right-click for view options" }
        ContextMenuContent do
          ContextMenuGroup do
            ContextMenuGroupLabel { "Show" }
            ContextMenuCheckboxItem(checked: true) { "Grid lines" }
            ContextMenuCheckboxItem { "Rulers" }
          end
          ContextMenuSeparator()
          ContextMenuRadioGroup(value: "fit") do
            ContextMenuGroupLabel { "Zoom" }
            ContextMenuRadioItem(value: "fit") { "Fit to screen" }
            ContextMenuRadioItem(value: "100") { "100%" }
            ContextMenuRadioItem(value: "200") { "200%" }
          end
        end
      end
    end
  end

  # @label RTL
  def rtl
    phlex do
      div(dir: "rtl") do
        ContextMenu do
          ContextMenuTrigger(class: AREA, tabindex: "0") { "انقر بزر الفأرة الأيمن هنا" }
          ContextMenuContent do
            ContextMenuItem { "نسخ" }
            ContextMenuSub do
              ContextMenuSubTrigger { "نقل إلى" }
              ContextMenuSubContent { ContextMenuItem { "المستندات" }; ContextMenuItem { "الأرشيف" } }
            end
            ContextMenuItem { "حذف" }
          end
        end
      end
    end
  end
end
