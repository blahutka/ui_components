# A labelled Field around one control, as AppicaUI::FormBuilder renders it: the label above the
# control (`layout: :stacked`), beside it (`:inline`, for a check box or switch) or shown by the
# control itself (`:control`, a toggle button's text).
class AppicaUI::FormBuilderField < AppicaUI::Base
  prop :field
  prop :label
  prop :description, default: -> { nil }
  prop :control
  prop :layout, one_of(%i[ stacked inline control ], :stacked), default: -> { :stacked }

  def view_template
    render AppicaUI::Field.new(**@field) do
      case @layout
      when :inline
        div(class: "flex items-start gap-2.5") do
          span(class: "flex h-5 shrink-0 items-center") { render @control }
          div(class: "flex min-w-0 flex-col") do
            render(AppicaUI::FieldLabel.new(class: "mb-0")) { @label }
            details
          end
        end
      when :control
        render @control
        details
      else
        render(AppicaUI::FieldLabel.new) { @label }
        render @control
        details
      end
    end
  end

  private
    def details
      render(AppicaUI::FieldDescription.new(class: ("mt-0.5" if @layout == :inline))) { @description } if @description
      render AppicaUI::FieldError.new
    end
end
