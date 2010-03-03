class AqCommit < ActiveRecord::Base
  belongs_to :branch, :class_name => "AqBranch", :foreign_key => "aq_branch_id"
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"
  has_and_belongs_to_many :aq_files
  
  def purge
  end
end
