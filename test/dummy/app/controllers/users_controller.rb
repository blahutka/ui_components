# The form builder demo: renders a form of `form.ui` fields and shows what `create` received.
class UsersController < ApplicationController
  layout "component_preview"

  def new
    @user = User.new(phones: [ Phone.new(kind: "mobile"), Phone.new(kind: "work") ])
  end

  def create
    @submitted_params = user_params
    @user = User.new(@submitted_params)

    if @user.valid?
      render :show
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.require(:user).permit(:name, :age, locations: [], address_attributes: %i[ city country ], phones_attributes: %i[ number kind ])
    end
end
