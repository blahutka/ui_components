# The form builder previews' submit target: shows the params a small form sent and the User
# validation errors for just those attributes (the rest of the User isn't in that form).
class FormSubmissionsController < ApplicationController
  layout "component_preview"

  def create
    @submitted_params = params.require(:user).permit(*User::PERMITTED)
    user = User.new(@submitted_params)
    user.valid?

    submitted = @submitted_params.keys.map { |key| key.delete_suffix("_attributes") }
    @errors = user.errors.select { |error| submitted.include?(error.attribute.to_s.split(".").first) }
  end
end
