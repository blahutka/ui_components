# Shared by ToolbarButton, ToolbarLink and ToolbarInput: a block taking an argument receives
# the item's attributes (Appica's `render` prop); otherwise the part renders its own element.
module AppicaUI::ToolbarItem
  def before_template(&content)
    @render_prop = content&.arity == 1
    super
  end

  private
    def toolbar
      consume(:ui_toolbar, component: "Toolbar")
    end

    def disabled?
      @attributes[:disabled] || context[:ui_toolbar_group]&.disabled? || toolbar.disabled?
    end

    def item_attributes(slot)
      {
        tabindex: "-1", aria_disabled: ("true" if disabled?),
        data: { slot:, orientation: toolbar.orientation, disabled: ("" if disabled?), "appica-ui--toolbar-target": "item" }
      }.compact
    end
end
