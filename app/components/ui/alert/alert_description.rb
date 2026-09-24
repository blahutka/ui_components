# The supporting body text.
class UI::AlertDescription < UI::Base
  def initialize(**attributes)
    @attributes = attributes
  end

  def view_template(&)
    p(**mix({ data: { slot: "alert-description" } }, @attributes.except(:class)),
      class: cn("text-foreground text-sm [grid-area:description] mt-2 @min-[460px]:group-data-[layout=inline]/alert:mt-0", override: @attributes[:class]), &)
  end
end
