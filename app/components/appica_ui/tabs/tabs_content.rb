# The panel for the TabsTrigger with the same `value:` - hidden unless its tab is selected.
class AppicaUI::TabsContent < AppicaUI::Base
  prop :value

  def view_template(&)
    tabs = consume(:ui_tabs, component: "Tabs")
    selected = tabs.selected?(@value)

    div(**mix({
      role: "tabpanel", id: tabs.panel_id(@value), aria_labelledby: tabs.trigger_id(@value), tabindex: "0", hidden: !selected,
      data: { slot: "tabs-content", orientation: tabs.orientation, value: @value.to_s, "appica-ui--tabs-target": "panel" }
    }, @attributes.except(:class)),
      class: cn("outline-none transition-[opacity,filter] duration-400 ease-out motion-reduce:transition-none data-[starting-style]:opacity-0", override: @attributes[:class]), &)
  end
end
