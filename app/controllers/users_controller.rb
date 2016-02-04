class UsersController < ApplicationController

  skip_before_action :ensure_login, only: [:create]

  def new
  end

  def create
  	@user = User.new(user_params)
  	if @user.save
      flash[:success] = 'You were successfully registered.'
      redirect_to login_path
  	else
      flash[:danger] = 'You could not be registered to the site.'
  		redirect_to login_path
  	end
  end

  def destroy
  end

  private
  	def user_params
      params.require(:user).permit(:email, :password)
  	end
end
