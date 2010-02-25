class AqCommit < ActiveRecord::Base
  belongs_to :branch, :class_name => :AqBranch
  belongs_to :author, :class_name => :User, :foreign_key => "author_id"
end
