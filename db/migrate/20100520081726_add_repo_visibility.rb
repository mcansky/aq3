class AddRepoVisibility < ActiveRecord::Migration
  def self.up
    add_column :aq_repositories, :visibility, :integer, :default => 0
  end

  def self.down
    remove_column :aq_repositories, :visibility
  end
end
