module ApplicationHelper
  def current_user
    @current_user_session = UserSession.find
  	@current_user = @current_user_session && @current_user_session.record
  	return @current_user
  end

  def is_even?(a)
    return true if (a%2 == 0)
    return false
  end

  def aq_logger(logfile, message)
    File.open(Rails.root + "/log/" + logfile, "a") do |log|
		  log.puts Time.now.strftime("%d/%m/%y %H:%M ") + message
	  end
  end
end
