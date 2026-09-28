# A ToggleGroup with one outline Button Toggle per choice, as AppicaUI::FormBuilder renders it.
class AppicaUI::FormBuilderToggleGroup < AppicaUI::Base
  prop :group
  prop :items
  prop :id

  def view_template
    render AppicaUI::ToggleGroup.new(**@group) do
      @items.each do |value, text|
        render(AppicaUI::Toggle.new(value:, id: "#{@id}_#{value}")) do |toggle|
          render(AppicaUI::Button.new(**toggle, variant: :outline)) { text }
        end
      end
    end
  end
end
