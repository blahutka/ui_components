# The <h2> that labels the popover.
class UI::PopoverTitle < UI::Base
  def view_template(&)
    popover = consume(:ui_popover, component: "Popover")
    h2(**mix({ id: popover.title_id, data: { slot: "popover-title" } }, @attributes.except(:class)),
      class: cn("text-foreground-intense text-base font-semibold", override: @attributes[:class]), &)
  end
end
