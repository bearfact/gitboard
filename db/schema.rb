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

ActiveRecord::Schema.define(version: 20150824015826) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "issues_status_issues", force: :cascade do |t|
    t.integer  "issue_id",                       null: false
    t.integer  "issues_status_id",   default: 1, null: false
    t.integer  "last_updated_by_id",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "issues_status_issues", ["last_updated_by_id"], name: "index_issues_status_issues_on_last_updated_by_id", using: :btree

  create_table "issues_statuses", force: :cascade do |t|
    t.integer  "repository_id"
    t.integer  "position",        null: false
    t.string   "name",            null: false
    t.string   "label",           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "repositories_id"
    t.integer  "sprint_id"
  end

  add_index "issues_statuses", ["repositories_id"], name: "index_issues_statuses_on_repositories_id", using: :btree

  create_table "repositories", force: :cascade do |t|
    t.integer  "user_id",     null: false
    t.string   "name",        null: false
    t.string   "owner",       null: false
    t.text     "description"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "users_id"
  end

  add_index "repositories", ["name", "owner", "user_id"], name: "index_repositories_on_name_and_owner_and_user_id", using: :btree
  add_index "repositories", ["users_id"], name: "index_repositories_on_users_id", using: :btree

  create_table "repository_users", force: :cascade do |t|
    t.integer "user_id",         null: false
    t.integer "repository_id",   null: false
    t.integer "users_id"
    t.integer "repositories_id"
  end

  add_index "repository_users", ["repositories_id"], name: "index_repository_users_on_repositories_id", using: :btree
  add_index "repository_users", ["users_id"], name: "index_repository_users_on_users_id", using: :btree

  create_table "sprint_issues", force: :cascade do |t|
    t.integer "sprint_id",                       null: false
    t.string  "repository",                      null: false
    t.string  "owner",                           null: false
    t.integer "issue_number",                    null: false
    t.float   "priority_position", default: 0.0
    t.integer "points",            default: 0,   null: false
    t.integer "sprints_id"
  end

  add_index "sprint_issues", ["sprints_id"], name: "index_sprint_issues_on_sprints_id", using: :btree

  create_table "sprints", force: :cascade do |t|
    t.integer  "user_id",              null: false
    t.string   "owner",                null: false
    t.string   "name",                 null: false
    t.datetime "due_date"
    t.integer  "status",   default: 1, null: false
    t.integer  "users_id"
  end

  add_index "sprints", ["users_id"], name: "index_sprints_on_users_id", using: :btree

  create_table "users", force: :cascade do |t|
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

  add_foreign_key "issues_status_issues", "users", column: "last_updated_by_id"
  add_foreign_key "issues_statuses", "repositories"
  add_foreign_key "repositories", "users"
  add_foreign_key "repository_users", "repositories"
  add_foreign_key "repository_users", "users"
  add_foreign_key "sprint_issues", "sprints"
  add_foreign_key "sprints", "users"
end
