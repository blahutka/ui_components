# A button that dismisses the drawer. Same render-prop convention as DrawerTrigger:
#
#   DrawerClose { |close| Button(**close) { "Save" } }
class UI::DrawerClose < UI::Base
  def initialize(**attributes)
    @attributes = attributes
  end

  def before_template(&content)
    @render_prop = content&.arity == 1
    super
  end

  def view_template
    attributes = mix({ type: "button", data: { slot: "drawer-close", action: "ui--drawer#close" } }, @attributes)

    if @render_prop
      yield attributes
    else
      button(**attributes) { yield }
    end
  end
end
