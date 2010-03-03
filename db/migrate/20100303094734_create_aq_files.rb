class CreateAqFiles < ActiveRecord::Migration
  def self.up
    create_table :aq_files do |t|
      t.string :name
      t.string :path
      t.timestamps
    end
    create_table :aq_commits_aq_files do |t|
      t.integer :aq_commit_id
      t.integer :aq_file_id
      t.timestamps
    end
  end

  def self.down
    drop_table :aq_files
  end
end
