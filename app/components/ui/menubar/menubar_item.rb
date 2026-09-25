# One action. Selecting it (click, Enter or Space) dispatches `ui--menubar:select` and closes
# the menu; `close_on_click: false` keeps it open. Tag a leading icon `data: { icon: "start" }`
# and push a trailing Kbd to the edge with `class: "ms-auto"`.
class UI::MenubarItem < UI::Base
  prop :disabled,       default: -> { false }
  prop :close_on_click, default: -> { true }
  prop :label,          default: -> { nil }

  def view_template(&)
    div(**mix(item_attributes, @attributes.except(:class)), class: cn(bar.item_classes, override: @attributes[:class]), &)
  end

  private
    def bar = consume(:ui_menubar, component: "Menubar")

    def item_attributes
      {
        role: "menuitem",
        tabindex: "-1",
        aria: { disabled: (@disabled ? "true" : nil) },
        data: {
          slot: "menubar-item",
          orientation: "vertical",
          disabled: (@disabled ? "" : nil),
          label: @label,
          close: @close_on_click.to_s
        }
      }
    end
end
