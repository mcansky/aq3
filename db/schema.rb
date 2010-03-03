# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100303094734) do

  create_table "aq_branches", :force => true do |t|
    t.string   "name"
    t.integer  "aq_repository_id"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "aq_commits", :force => true do |t|
    t.string   "sha"
    t.text     "log"
    t.integer  "aq_branch_id"
    t.integer  "author_id"
    t.string   "author_name"
    t.datetime "committed_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "aq_repository_id"
  end

  create_table "aq_commits_aq_files", :id => false, :force => true do |t|
    t.integer  "aq_commit_id"
    t.integer  "aq_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "aq_files", :force => true do |t|
    t.string   "name"
    t.string   "path"
    t.integer  "aq_branch_id"
    t.integer  "aq_repository_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "aq_repositories", :force => true do |t|
    t.string   "name"
    t.string   "path"
    t.string   "kind",       :default => "git"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "desc"
    t.integer  "parent_id"
  end

  create_table "beans", :force => true do |t|
    t.integer  "user_id"
    t.integer  "aq_repository_id"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rights", :force => true do |t|
    t.integer  "user_id"
    t.integer  "ssh_key_id"
    t.integer  "aq_repository_id"
    t.string   "right"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
  end

  create_table "ssh_keys", :force => true do |t|
    t.string   "name",       :default => "default"
    t.text     "key"
    t.string   "login"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_sessions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "login"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
