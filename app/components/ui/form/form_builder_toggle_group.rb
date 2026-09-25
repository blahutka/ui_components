# A ToggleGroup with one outline Button Toggle per choice, as UI::FormBuilder renders it.
class UI::FormBuilderToggleGroup < UI::Base
  prop :group
  prop :items
  prop :id

  def view_template
    render UI::ToggleGroup.new(**@group) do
      @items.each do |value, text|
        render(UI::Toggle.new(value:, id: "#{@id}_#{value}")) do |toggle|
          render(UI::Button.new(**toggle, variant: :outline)) { text }
        end
      end
    end
  end
end
