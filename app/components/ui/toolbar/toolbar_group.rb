# Related toolbar items under one `role="group"` - name it with aria_label:.
class UI::ToolbarGroup < UI::Base
  prop :disabled, default: -> { false }

  def disabled? = @disabled

  def view_template(&)
    toolbar = consume(:ui_toolbar, component: "Toolbar")
    provide(:ui_toolbar_group, self) do
      div(**mix({ role: "group", data: { slot: "toolbar-group", orientation: toolbar.orientation, disabled: ("" if @disabled) } }, @attributes.except(:class)),
        class: cn("flex items-center gap-1 data-[orientation=vertical]:flex-col", override: @attributes[:class]), &)
    end
  end
end
