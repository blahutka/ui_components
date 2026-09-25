# A labelled group of CommandItems in a CommandMenu; hidden while none of its items match.
class Blocks::CommandGroup < Blocks::Base
  prop :label, default: -> { nil }

  def view_template(&)
    div(**mix({ data: { slot: "command-group", "blocks--command-menu-target": "group" } }, @attributes.except(:class)), class: @attributes[:class]) do
      div(class: "text-foreground-subtle px-2 pb-1.5 text-xs", data: { slot: "command-group-label" }) { @label } if @label
      NavigationList(&)
    end
  end
end
