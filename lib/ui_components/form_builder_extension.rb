module UiComponents
  # `form.ui` on every Rails form builder - see UI::FormBuilder.
  module FormBuilderExtension
    def ui
      UI::FormBuilder.new(self)
    end
  end

  # `form.ui` on the builder phlex-rails' form_with / fields_for yield: every helper's HTML goes
  # straight into the component's output, like `form.text_field` does there - no `raw` needed.
  module PhlexFormBuilderExtension
    def ui
      ::Phlex::Rails::Buffered.new(@object.ui, component: @component)
    end
  end
end
