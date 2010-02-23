class Right < ActiveRecord::Base
  belongs_to :user
  belongs_to :aq_repository
  belongs_to :ssh_key

  def pending?
    return true if self.status == "p"
    return false
  end

  def accepted?
    return true if self.status == "a"
    return false
  end

  def rejected?
    return true if self.status == "r"
    return false
  end
end
