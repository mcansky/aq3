class User < ActiveRecord::Base
  acts_as_authentic
  has_many :ssh_keys
  has_many :rights
  has_many :aq_repositories, :through => :rights
  has_many :aq_commits, :foreign_key => "author_id", :order => "committed_time DESC"

  def self.find_by_login_or_email(login)
    find_by_login(login) || find_by_email(login)
  end

  def max_beans?
    return true if self.beans.size == 10
  end
end
