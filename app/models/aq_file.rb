class AqFile < ActiveRecord::Base
  has_and_belongs_to_many :aq_commits, :order => "committed_time asc"
  belongs_to :branch, :class_name => "AqBranch", :foreign_key => "aq_branch_id"
end
