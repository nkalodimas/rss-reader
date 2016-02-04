class SessionsController < ApplicationController

  skip_before_action :ensure_login, only: [:new, :create]
  
  def new
  end

  def create
  	user = User.find_by(email: params[:user][:email])
  	password = params[:user][:password]
  	if user && user.authenticate(password)
  		session[:user_id] = user.id
  		# Refresh last_login
  		user.update(last_login: DateTime.now)
      flash[:success] = 'Logged in successfully.'
  		redirect_to root_path
  	else
      flash[:danger] = 'User was not authenticated.'
  		redirect_to login_path
  	end
  end

  def destroy
  	reset_session
    flash[:success] = 'You have been logged out'
  	redirect_to login_path
  end
end