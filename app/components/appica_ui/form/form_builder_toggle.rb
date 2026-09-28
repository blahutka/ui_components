# A Toggle painted as an outline Button, as AppicaUI::FormBuilder renders it: the button shows the
# label, the Field around it the description and error.
class AppicaUI::FormBuilderToggle < AppicaUI::Base
  prop :toggle
  prop :text
  prop :button, default: -> { {} }

  def view_template
    render(AppicaUI::Toggle.new(**@toggle)) do |toggle|
      render(AppicaUI::Button.new(**toggle, variant: :outline, **@button)) { @text }
    end
  end
end
