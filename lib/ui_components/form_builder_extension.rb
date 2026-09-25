module UiComponents
  # `form.ui` on every Rails form builder - see UI::FormBuilder.
  module FormBuilderExtension
    def ui
      UI::FormBuilder.new(self)
    end
  end
end
