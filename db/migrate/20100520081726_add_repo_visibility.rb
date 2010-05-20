class AddRepoVisibility < ActiveRecord::Migration
  def self.up
    add_column :aq_repositories, :visibility, :integer
  end

  def self.down
    remove_column :aq_repositories, :visibility
  end
end
