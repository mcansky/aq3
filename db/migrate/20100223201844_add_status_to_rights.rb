class AddStatusToRights < ActiveRecord::Migration
  def self.up
    add_column :rights, :status, :string
  end

  def self.down
    remove_column :rights, :status
  end
end
