# The text column. It stretches (flex-1), which pins CardFooter to the bottom of a
# fixed-height card. Any content fits: it's a plain flex column.
class UI::CardHeader < UI::Base
  def initialize(**attributes)
    @attributes = attributes
  end

  def view_template(&)
    div(**mix({ data: { slot: "card-header" } }, @attributes.except(:class)),
        class: cn("flex flex-1 flex-col gap-1.5 p-6 group-data-inset/card:px-4", override: @attributes[:class]), &)
  end
end
