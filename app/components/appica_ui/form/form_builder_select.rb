# A Select with a trigger, value and one item per choice, as AppicaUI::FormBuilder renders it.
class AppicaUI::FormBuilderSelect < AppicaUI::Base
  prop :select
  prop :trigger
  prop :placeholder, default: -> { nil }
  prop :items

  def view_template
    render AppicaUI::Select.new(**@select) do
      render(AppicaUI::SelectTrigger.new(**@trigger.compact)) { render AppicaUI::SelectValue.new(placeholder: @placeholder) }
      render AppicaUI::SelectContent.new do
        @items.each { |value, label| render(AppicaUI::SelectItem.new(value:)) { label } }
      end
    end
  end
end
