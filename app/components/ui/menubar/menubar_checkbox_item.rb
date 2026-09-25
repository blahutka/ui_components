# A toggleable item with a check indicator. Keeps the menu open and dispatches
# `ui--menubar:checked-change` with { checked, item }.
class UI::MenubarCheckboxItem < UI::Base
  prop :checked,        default: -> { false }
  prop :disabled,       default: -> { false }
  prop :close_on_click, default: -> { false }
  prop :label,          default: -> { nil }

  def view_template(&)
    div(**mix({
      role: "menuitemcheckbox",
      tabindex: "-1",
      aria: { checked: @checked.to_s, disabled: (@disabled ? "true" : nil) },
      data: {
        slot: "menubar-checkbox-item",
        orientation: "vertical",
        checked: (@checked ? "" : nil),
        unchecked: (@checked ? nil : ""),
        disabled: (@disabled ? "" : nil),
        label: @label,
        close: @close_on_click.to_s
      }
    }, @attributes.except(:class)), class: cn(bar.item_classes, "justify-between", override: @attributes[:class])) do
      span(class: "flex items-center gap-1.5", &)
      render UI::MenubarCheckIndicator.new(checked: @checked, slot: "menubar-checkbox-item-indicator")
    end
  end

  private
    def bar = consume(:ui_menubar, component: "Menubar")
end
