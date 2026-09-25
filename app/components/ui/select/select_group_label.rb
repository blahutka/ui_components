# The visible label of a SelectGroup.
class UI::SelectGroupLabel < UI::Base
  SIZES = { sm: "px-2.5 pt-1.5 pb-1 text-xs", md: "px-3 pt-2 pb-1.25 text-sm", lg: "px-3.5 pt-2.5 pb-1.5 text-base" }.freeze

  def view_template(&)
    div(**mix({ id: context[:ui_select_group]&.label_id, data: { slot: "select-group-label" } }, @attributes.except(:class)),
      class: cn("text-foreground-subtle", SIZES[consume(:ui_select, component: "Select").size], override: @attributes[:class]), &)
  end
end
