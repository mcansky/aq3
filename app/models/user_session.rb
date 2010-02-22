class UserSession < Authlogic::Session::Base
  find_by_login_method :find_by_login_or_email
  generalize_credentials_error_messages t(:login_fail)
end
