class Bean < ActiveRecord::Base
  belongs_to :user
  belongs_to :aq_repository
end
