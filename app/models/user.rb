class User < ActiveRecord::Base
  acts_as_authentic
  has_many :ssh_keys
  has_many :rights
  has_many :aq_repositories, :through => :rights
  has_many :aq_commits, :foreign_key => "author_id"
  has_many :beans
  has_many :beaned_repositories, :through => :beans, :source => :aq_repository

  def self.find_by_login_or_email(login)
    find_by_login(login) || find_by_email(login)
  end

  def max_beans?
    return true if self.beans.size == 10
  end
end
