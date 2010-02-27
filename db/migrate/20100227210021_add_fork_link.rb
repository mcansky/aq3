class AddForkLink < ActiveRecord::Migration
  def self.up
    add_column :aq_repositories, :parent_id, :integer
  end

  def self.down
    remove_column :aq_repositories, :parent_id
  end
end
