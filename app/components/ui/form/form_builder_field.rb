# A labelled Field around one control, as UI::FormBuilder renders it: the label above the
# control, or (`inline: true`, for a check box or switch) beside it.
class UI::FormBuilderField < UI::Base
  prop :field
  prop :label
  prop :description, default: -> { nil }
  prop :control
  prop :inline, default: -> { false }

  def view_template
    render UI::Field.new(**@field) do
      if @inline
        div(class: "flex items-start gap-2.5") do
          span(class: "flex h-5 shrink-0 items-center") { render @control }
          div(class: "flex min-w-0 flex-col") do
            render(UI::FieldLabel.new(class: "mb-0")) { @label }
            details
          end
        end
      else
        render(UI::FieldLabel.new) { @label }
        render @control
        details
      end
    end
  end

  private
    def details
      render(UI::FieldDescription.new(class: ("mt-0.5" if @inline))) { @description } if @description
      render UI::FieldError.new
    end
end
