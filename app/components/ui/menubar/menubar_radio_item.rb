# One option in a MenubarRadioGroup. Keeps the menu open when chosen.
class UI::MenubarRadioItem < UI::Base
  prop :value,          proc(&:to_s)
  prop :disabled,       default: -> { false }
  prop :close_on_click, default: -> { false }
  prop :label,          default: -> { nil }

  def view_template(&)
    checked = group&.value == @value

    div(**mix({
      role: "menuitemradio",
      tabindex: "-1",
      aria: { checked: checked.to_s, disabled: (@disabled ? "true" : nil) },
      data: {
        slot: "menubar-radio-item",
        orientation: "vertical",
        value: @value,
        checked: (checked ? "" : nil),
        unchecked: (checked ? nil : ""),
        disabled: (@disabled ? "" : nil),
        label: @label,
        close: @close_on_click.to_s
      }
    }, @attributes.except(:class)), class: cn(bar.item_classes, "justify-between", override: @attributes[:class])) do
      span(class: "flex items-center gap-1.5", &)
      render UI::MenubarCheckIndicator.new(checked:, slot: "menubar-radio-item-indicator")
    end
  end

  private
    def bar = consume(:ui_menubar, component: "Menubar")
    def group = context[:ui_menubar_radio_group]
end
