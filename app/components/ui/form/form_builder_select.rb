# A Select with a trigger, value and one item per choice, as UI::FormBuilder renders it.
class UI::FormBuilderSelect < UI::Base
  prop :select
  prop :trigger
  prop :placeholder, default: -> { nil }
  prop :items

  def view_template
    render UI::Select.new(**@select) do
      render(UI::SelectTrigger.new(**@trigger.compact)) { render UI::SelectValue.new(placeholder: @placeholder) }
      render UI::SelectContent.new do
        @items.each { |value, label| render(UI::SelectItem.new(value:)) { label } }
      end
    end
  end
end
