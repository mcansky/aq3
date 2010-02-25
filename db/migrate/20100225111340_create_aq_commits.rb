class CreateAqCommits < ActiveRecord::Migration
  def self.up
    create_table :aq_commits do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :aq_commits
  end
end
