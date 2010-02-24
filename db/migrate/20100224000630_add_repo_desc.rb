class AddRepoDesc < ActiveRecord::Migration
  def self.up
    add_column :aq_repositories, :desc, :text
  end

  def self.down
    remove_column :aq_repositories, :desc
  end
end
