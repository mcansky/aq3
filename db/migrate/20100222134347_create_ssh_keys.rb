class CreateSshKeys < ActiveRecord::Migration
  def self.up
    create_table :ssh_keys do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :ssh_keys
  end
end
