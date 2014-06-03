# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140603031805) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "issues_status_issues", force: true do |t|
    t.integer  "issue_id",                       null: false
    t.integer  "issues_status_id",   default: 1, null: false
    t.integer  "last_updated_by_id",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issues_status_issues", ["last_updated_by_id"], name: "index_issues_status_issues_on_last_updated_by_id", using: :btree

  create_table "issues_statuses", force: true do |t|
    t.integer  "repository_id", null: false
    t.integer  "position",      null: false
    t.string   "name",          null: false
    t.string   "label",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issues_statuses", ["repository_id"], name: "index_issues_statuses_on_repository_id", using: :btree

  create_table "repositories", force: true do |t|
    t.integer  "user_id",     null: false
    t.string   "name",        null: false
    t.string   "owner",       null: false
    t.text     "description"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "repositories", ["name", "owner", "user_id"], name: "index_repositories_on_name_and_owner_and_user_id", using: :btree
  add_index "repositories", ["user_id"], name: "index_repositories_on_user_id", using: :btree

  create_table "repository_users", force: true do |t|
    t.integer "user_id",       null: false
    t.integer "repository_id", null: false
  end

  add_index "repository_users", ["repository_id"], name: "index_repository_users_on_repository_id", using: :btree
  add_index "repository_users", ["user_id"], name: "index_repository_users_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "provider",                          null: false
    t.string   "login",                             null: false
    t.string   "uid",                               null: false
    t.string   "name"
    t.string   "oauth_token",                       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_url"
    t.hstore   "issues_board_settings"
    t.integer  "status_id",             default: 0, null: false
    t.string   "email"
  end

  add_foreign_key "issues_status_issues", "users", name: "issues_status_issues_last_updated_by_id_fk", column: "last_updated_by_id"

  add_foreign_key "issues_statuses", "repositories", name: "issues_statuses_repository_id_fk"

  add_foreign_key "repositories", "users", name: "repositories_user_id_fk"

  add_foreign_key "repository_users", "repositories", name: "repository_users_repository_id_fk"
  add_foreign_key "repository_users", "users", name: "repository_users_user_id_fk"

end
