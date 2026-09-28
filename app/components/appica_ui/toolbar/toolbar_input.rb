# An input in the toolbar's focus order - the arrow keys leave it only at the text's edges.
#
#   ToolbarInput(class: "w-44") { |item| Input(**item, start_slot: :search, placeholder: "Search…") }
class AppicaUI::ToolbarInput < AppicaUI::Base
  include AppicaUI::ToolbarItem

  def view_template(&)
    attributes = mix(item_attributes("toolbar-input"), @attributes.except(:class))

    if @render_prop
      div(class: cn("flex", @attributes[:class])) { yield attributes }
    else
      input(**attributes, class: @attributes[:class])
    end
  end
end
