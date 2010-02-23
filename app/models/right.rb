class Right < ActiveRecord::Base
  belongs_to :user
  belongs_to :aq_repository
  belongs_to :ssh_key
  
  def initialize(user, repository, right, role)
    self.user = user
    self.aq_repository = repository
    self.right = right
    self.role = role
  end
end
