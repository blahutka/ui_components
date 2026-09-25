# Rails form helpers backed by the UI components, with model values and validation.
#
# @label Form builder
# @logical_path Actions & Inputs
# @display width wide
class UI::FormBuilderPreview < UI::BasePreview
  # Submit to the dummy app to inspect the ordinary Rails params and model validation.
  # @param browser_validation [Boolean] toggle "Browser validation"
  def default(browser_validation: true)
    render_with_template(template: "ui/form/form_builder_preview/default", locals: { user: User.new_with_blank_children, browser_validation: })
  end
end
