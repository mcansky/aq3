class CreateAqFiles < ActiveRecord::Migration
  def self.up
    create_table :aq_files do |t|
      t.string :name
      t.string :path
      t.integer :aq_branch_id, :default => 0
      t.integer :aq_repository_id, :default => 0
      t.timestamps
    end
    create_table :aq_commits_aq_files, :id => false do |t|
      t.integer :aq_commit_id
      t.integer :aq_file_id
      t.timestamps
    end
    add_column :aq_commits, :aq_repository_id, :integer
  end

  def self.down
    drop_table :aq_files
    drop_table :aq_commits_aq_files
    remove_column :aq_commits, :aq_repository_id
  end
end
