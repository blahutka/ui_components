# A labelled Field around one control, as UI::FormBuilder renders it: the label above the
# control (`layout: :stacked`), beside it (`:inline`, for a check box or switch) or shown by the
# control itself (`:control`, a toggle button's text).
class UI::FormBuilderField < UI::Base
  prop :field
  prop :label
  prop :description, default: -> { nil }
  prop :control
  prop :layout, one_of(%i[ stacked inline control ], :stacked), default: -> { :stacked }

  def view_template
    render UI::Field.new(**@field) do
      case @layout
      when :inline
        div(class: "flex items-start gap-2.5") do
          span(class: "flex h-5 shrink-0 items-center") { render @control }
          div(class: "flex min-w-0 flex-col") do
            render(UI::FieldLabel.new(class: "mb-0")) { @label }
            details
          end
        end
      when :control
        render @control
        details
      else
        render(UI::FieldLabel.new) { @label }
        render @control
        details
      end
    end
  end

  private
    def details
      render(UI::FieldDescription.new(class: ("mt-0.5" if @layout == :inline))) { @description } if @description
      render UI::FieldError.new
    end
end
