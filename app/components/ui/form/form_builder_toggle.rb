# A Toggle painted as an outline Button, as UI::FormBuilder renders it: the button shows the
# label, the Field around it the description and error.
class UI::FormBuilderToggle < UI::Base
  prop :toggle
  prop :text
  prop :button, default: -> { {} }

  def view_template
    render(UI::Toggle.new(**@toggle)) do |toggle|
      render(UI::Button.new(**toggle, variant: :outline, **@button)) { @text }
    end
  end
end
