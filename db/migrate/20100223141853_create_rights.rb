class CreateRights < ActiveRecord::Migration
  def self.up
    create_table :rights do |t|
      t.integer :user_id
      t.integer :ssh_key_id
      t.integer :aq_repository_id
      t.string :right
      t.string :role
      t.timestamps
    end
  end

  def self.down
    drop_table :rights
  end
end
