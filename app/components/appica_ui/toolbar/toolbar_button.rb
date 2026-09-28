# A toolbar button. Pass a block with an argument to put the attributes on your own control:
#
#   ToolbarButton { |item| Button(**item, variant: :ghost, icon: true, aria_label: "Bold") { Icon(:bold) } }
#
# Disabled items stay reachable (aria-disabled) so keyboard users can still read them.
class AppicaUI::ToolbarButton < AppicaUI::Base
  include AppicaUI::ToolbarItem

  def view_template(&)
    attributes = mix(item_attributes("toolbar-button"), @attributes.except(:disabled))

    if @render_prop
      yield attributes
    else
      button(type: "button", **attributes, &)
    end
  end
end
