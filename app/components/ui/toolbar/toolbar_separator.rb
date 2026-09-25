# A divider across the toolbar's axis (vertical in a horizontal toolbar, and vice versa).
class UI::ToolbarSeparator < UI::Base
  prop :orientation, default: -> { nil }

  def view_template
    toolbar = consume(:ui_toolbar, component: "Toolbar")
    orientation = @orientation || (toolbar.orientation == :horizontal ? :vertical : :horizontal)

    div(**mix({ role: "separator", aria_orientation: orientation, data: { slot: "toolbar-separator", orientation: } }, @attributes.except(:class)),
      class: cn("bg-border shrink-0 data-[orientation=vertical]:mx-0.5 data-[orientation=vertical]:h-5 data-[orientation=vertical]:w-(--border-width) " \
        "data-[orientation=horizontal]:my-0.5 data-[orientation=horizontal]:h-(--border-width) data-[orientation=horizontal]:w-full", override: @attributes[:class]))
  end
end
