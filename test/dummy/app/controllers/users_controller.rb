# The form builder demo: renders a form of `form.ui` fields, saves the User (with its address
# and phones) and shows what `create` received.
class UsersController < ApplicationController
  layout "component_preview"

  def new
    @user = User.new_with_blank_children
  end

  def create
    @submitted_params = user_params
    @user = User.new(@submitted_params)

    if @user.save
      render :show
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.require(:user).permit(*User::PERMITTED)
    end
end
