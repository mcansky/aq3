class UserSessionsController < ApplicationController
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = t(:login_ok)
			if active_order?
				session[:active_order] = active_order.id
			end
	   	redirect_to root_url
    else
      redirect_to :action => 'new'
    end
  end
  
  def destroy
    @user_session = UserSession.find
		session[:active_order] = nil
    @user_session.destroy
    flash[:notice] = t(:logout_ok)
    redirect_to root_url
  end
end
