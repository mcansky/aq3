class AqBranch < ActiveRecord::Base
  belongs_to :aq_repository
  has_many :commits, :class_name => :AqCommit, :order => "commited_time"
end
