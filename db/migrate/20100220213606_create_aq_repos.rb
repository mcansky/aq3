class CreateAqRepos < ActiveRecord::Migration
  def self.up
    create_table :aq_repos do |t|
      t.string :name
      t.string :path
      t.string :type, :default => "git"
      t.timestamps
    end
  end

  def self.down
    drop_table :aq_repos
  end
end
