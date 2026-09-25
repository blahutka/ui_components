# A labelled Field around one control, as UI::FormBuilder renders it.
class UI::FormBuilderField < UI::Base
  prop :field
  prop :label
  prop :description, default: -> { nil }
  prop :control

  def view_template
    render UI::Field.new(**@field) do
      render(UI::FieldLabel.new) { @label }
      render @control
      render(UI::FieldDescription.new) { @description } if @description
      render UI::FieldError.new
    end
  end
end
