class CreateAqFiles < ActiveRecord::Migration
  def self.up
    create_table :aq_files do |t|
      t.string :name
      t.string :path
      t.integer :aq_branch_id
      t.timestamps
    end
    create_table :aq_commits_aq_files, :id => false do |t|
      t.integer :aq_commit_id
      t.integer :aq_file_id
      t.timestamps
    end
  end

  def self.down
    drop_table :aq_files
    drop_table :aq_commits_aq_files
  end
end
