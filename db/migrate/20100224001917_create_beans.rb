class CreateBeans < ActiveRecord::Migration
  def self.up
    create_table :beans do |t|
      t.integer :user_id
      t.integer :aq_repository_id
      t.string :kind
      t.timestamps
    end
  end

  def self.down
    drop_table :beans
  end
end
