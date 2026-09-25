# The <p> that describes the popover.
class UI::PopoverDescription < UI::Base
  def view_template(&)
    popover = consume(:ui_popover, component: "Popover")
    p(**mix({ id: popover.description_id, data: { slot: "popover-description" } }, @attributes.except(:class)), class: cn("text-sm", override: @attributes[:class]), &)
  end
end
