# A row for actions. Below the sm breakpoint it stacks in reverse, so the primary
# (first) action sits on top on narrow screens.
class UI::CardFooter < UI::Base
  def initialize(**attributes)
    @attributes = attributes
  end

  def view_template(&)
    div(**mix({ data: { slot: "card-footer" } }, @attributes.except(:class)),
        class: cn("flex flex-col-reverse gap-2 px-6 pb-6 sm:flex-row sm:items-center group-data-inset/card:px-4 group-data-inset/card:pb-4", override: @attributes[:class]), &)
  end
end
