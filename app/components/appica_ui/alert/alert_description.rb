# The supporting body text.
class AppicaUI::AlertDescription < AppicaUI::Base
  def view_template(&)
    p(**mix({ data: { slot: "alert-description" } }, @attributes.except(:class)),
      class: cn("text-foreground text-sm [grid-area:description] mt-2 @min-[460px]:group-data-[layout=inline]/alert:mt-0", override: @attributes[:class]), &)
  end
end
