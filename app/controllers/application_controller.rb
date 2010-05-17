class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user_session, :current_user, :login_required, :aq_logger

  def index
    @repositories = AqRepository.find(:all)
    @commits = AqCommit.find(:all, :order => "committed_time DESC")
  end

	private
	def current_user_session
		return @current_user_session if defined?(@current_user_session)
		@current_user_session = UserSession.find
	end

	def current_user
		return @current_user if defined?(@current_user)
		@current_user = current_user_session && current_user_session.record
	end

	def login_required
    if current_user
      return true
    else
      flash[:notice] = t(:login_required)
      redirect_to login_path
    end
  end

end
