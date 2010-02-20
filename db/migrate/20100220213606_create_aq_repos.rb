class CreateAqRepos < ActiveRecord::Migration
  def self.up
    create_table :aq_repositories do |t|
      t.string :name
      t.string :path
      t.string :kind, :default => "git"
      t.timestamps
    end
  end

  def self.down
    drop_table :aq_repositories
  end
end
