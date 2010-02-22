class CreateSshKeys < ActiveRecord::Migration
  def self.up
    create_table :ssh_keys do |t|
      t.name :name, :default => "default"
      t.key :key
      t.login :login
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :ssh_keys
  end
end
