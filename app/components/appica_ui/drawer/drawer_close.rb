# A button that dismisses the drawer. Same render-prop convention as DrawerTrigger:
#
#   DrawerClose { |close| Button(**close) { "Save" } }
class AppicaUI::DrawerClose < AppicaUI::Base
  def before_template(&content)
    @render_prop = content&.arity == 1
    super
  end

  def view_template
    attributes = mix({ type: "button", data: { slot: "drawer-close", action: "appica-ui--drawer#close" } }, @attributes)

    if @render_prop
      yield attributes
    else
      button(**attributes) { yield }
    end
  end
end
