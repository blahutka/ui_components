# A labelled section of a Select's list: SelectGroupLabel plus its SelectItems.
class UI::SelectGroup < UI::Base
  def view_template(&)
    @label_id = "select-group-#{SecureRandom.hex(3)}"
    provide(:ui_select_group, self) do
      div(**mix({ role: "group", aria_labelledby: @label_id, data: { slot: "select-group" } }, @attributes), &)
    end
  end

  attr_reader :label_id
end
