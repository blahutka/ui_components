# A link in the toolbar's focus order: `ToolbarLink(href: "#help", class: "…") { "Help" }`, or
# a block with an argument for your own link.
class UI::ToolbarLink < UI::Base
  include UI::ToolbarItem

  def view_template(&)
    attributes = mix(item_attributes("toolbar-link"), @attributes)

    if @render_prop
      yield attributes
    else
      a(**attributes, &)
    end
  end
end
