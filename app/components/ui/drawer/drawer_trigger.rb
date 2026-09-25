# The button that opens the drawer. A block taking an argument receives the
# trigger attributes to put on your own element (Appica's `render` prop):
#
#   DrawerTrigger { |trigger| Button(**trigger, variant: :outline) { "Open" } }
#   DrawerTrigger(class: "underline") { "Open" }   # plain <button>
class UI::DrawerTrigger < UI::Base
  def before_template(&content)
    @render_prop = content&.arity == 1
    super
  end

  def view_template
    attributes = mix(trigger_attributes, @attributes)

    if @render_prop
      yield attributes
    else
      button(**attributes) { yield }
    end
  end

  private
    def drawer = consume(:ui_drawer, component: "Drawer")

    def trigger_attributes
      {
        type: "button",
        aria: { haspopup: "dialog", expanded: "false", controls: drawer.dialog_id },
        data: { slot: "drawer-trigger", "ui--drawer-target": "trigger", action: "ui--drawer#open" }
      }
    end
end
