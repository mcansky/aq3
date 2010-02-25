class CreateAqBranches < ActiveRecord::Migration
  def self.up
    create_table :aq_branches do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :aq_branches
  end
end
