# A trailing row for buttons: below the text in the block layout, after it inline.
class UI::AlertAction < UI::Base
  def view_template(&)
    div(**mix({ data: { slot: "alert-action" } }, @attributes.except(:class)), class: cn(
      "flex justify-end gap-2 [grid-area:actions] pt-2",
      "@min-[460px]:group-data-[layout=inline]/alert:ms-3 @min-[460px]:group-data-[layout=inline]/alert:pt-0",
      override: @attributes[:class]
    ), &)
  end
end
