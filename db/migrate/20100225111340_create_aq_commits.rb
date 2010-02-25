class CreateAqCommits < ActiveRecord::Migration
  def self.up
    create_table :aq_commits do |t|
      t.string   "sha"
      t.text     "log"
      t.integer  "aq_branch_id"
      t.integer  "author_id"
      t.string   "author_name"
      t.datetime "commited_time"
      t.timestamps
    end
  end

  def self.down
    drop_table :aq_commits
  end
end
