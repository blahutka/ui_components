module UiComponents
  # `form.ux` on every Rails form builder - see AppicaUI::FormBuilder.
  module FormBuilderExtension
    def ux
      AppicaUI::FormBuilder.new(self)
    end
  end

  # `form.ux` on the builder phlex-rails' form_with / fields_for yield: every helper's HTML goes
  # straight into the component's output, like `form.text_field` does there - no `raw` needed.
  module PhlexFormBuilderExtension
    def ux
      ::Phlex::Rails::Buffered.new(@object.ux, component: @component)
    end
  end
end
