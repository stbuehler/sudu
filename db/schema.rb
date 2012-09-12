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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120812184818) do

  create_table "admins", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true

  create_table "project_roles", :force => true do |t|
    t.string  "name"
    t.integer "project_id", :null => false
    t.text    "abilities"
  end

  add_index "project_roles", ["project_id"], :name => "index_project_roles_on_project_id"

  create_table "project_roles_users", :id => false, :force => true do |t|
    t.integer "project_role_id", :null => false
    t.integer "user_id",         :null => false
  end

  add_index "project_roles_users", ["project_role_id", "user_id"], :name => "index_project_roles_users_on_project_role_id_and_user_id", :unique => true
  add_index "project_roles_users", ["project_role_id"], :name => "index_project_roles_users_on_project_role_id"
  add_index "project_roles_users", ["user_id"], :name => "index_project_roles_users_on_user_id"

  create_table "projects", :force => true do |t|
    t.string "name"
  end

  create_table "todo_item_changes", :force => true do |t|
    t.integer  "todo_item_id", :null => false
    t.integer  "user_id",      :null => false
    t.text     "status"
    t.text     "comment"
    t.text     "description"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "todo_item_changes", ["todo_item_id"], :name => "index_todo_item_changes_on_todo_item_id"
  add_index "todo_item_changes", ["user_id"], :name => "index_todo_item_changes_on_user_id"

  create_table "todo_items", :force => true do |t|
    t.integer  "todo_list_id", :null => false
    t.string   "title",        :null => false
    t.boolean  "open",         :null => false
    t.date     "suspend_till"
    t.integer  "priority",     :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "todo_items", ["open"], :name => "index_todo_items_on_open"
  add_index "todo_items", ["todo_list_id"], :name => "index_todo_items_on_todo_list_id"

  create_table "todo_items_users", :id => false, :force => true do |t|
    t.integer "todo_item_id", :null => false
    t.integer "user_id",      :null => false
  end

  add_index "todo_items_users", ["todo_item_id", "user_id"], :name => "index_todo_items_users_on_todo_item_id_and_user_id", :unique => true
  add_index "todo_items_users", ["todo_item_id"], :name => "index_todo_items_users_on_todo_item_id"
  add_index "todo_items_users", ["user_id"], :name => "index_todo_items_users_on_user_id"

  create_table "todo_lists", :force => true do |t|
    t.integer  "project_id", :null => false
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "todo_lists", ["project_id"], :name => "index_todo_lists_on_project_id"

  create_table "users", :force => true do |t|
    t.string   "username",                                     :null => false
    t.datetime "deleted_at"
    t.boolean  "locked",                    :default => false, :null => false
    t.string   "feed_authentication_token",                    :null => false
    t.string   "email",                     :default => "",    :null => false
    t.string   "encrypted_password",        :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["feed_authentication_token"], :name => "index_users_on_feed_authentication_token", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
