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

ActiveRecord::Schema.define(:version => 20110427001458) do

  create_table "categories", :force => true do |t|
    t.integer  "group_id"
    t.string   "name"
    t.integer  "depth"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.text     "description"
  end

  add_index "categories", ["group_id"], :name => "index_categories_on_group_id"

  create_table "examples", :force => true do |t|
    t.integer  "ling_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
    t.integer  "creator_id"
  end

  create_table "examples_lings_properties", :force => true do |t|
    t.integer  "example_id"
    t.integer  "lings_property_id"
    t.integer  "creator_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ling0_name"
    t.string   "ling1_name"
    t.string   "property_name"
    t.string   "category_name"
    t.string   "lings_property_name"
    t.string   "example_name"
    t.string   "examples_lings_property_name"
    t.integer  "depth_maximum"
    t.string   "privacy"
    t.text     "example_fields"
  end

  create_table "lings", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "depth"
    t.integer  "parent_id"
    t.integer  "group_id"
    t.integer  "creator_id"
  end

  add_index "lings", ["group_id"], :name => "index_lings_on_group_id"

  create_table "lings_properties", :force => true do |t|
    t.integer  "ling_id"
    t.integer  "property_id"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
    t.integer  "creator_id"
    t.string   "property_value"
  end

  add_index "lings_properties", ["group_id"], :name => "index_lings_properties_on_group_id"
  add_index "lings_properties", ["ling_id", "property_id"], :name => "index_lings_properties_on_ling_id_and_property_id"
  add_index "lings_properties", ["property_value"], :name => "index_lings_properties_on_property_value"

  create_table "memberships", :force => true do |t|
    t.integer  "member_id"
    t.integer  "group_id"
    t.string   "level"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
  end

  create_table "properties", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
    t.integer  "category_id"
    t.integer  "creator_id"
    t.text     "description"
  end

  add_index "properties", ["group_id"], :name => "index_properties_on_group_id"

  create_table "searches", :force => true do |t|
    t.string   "name",        :null => false
    t.integer  "creator_id",  :null => false
    t.integer  "group_id",    :null => false
    t.text     "query"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "parent_ids"
    t.text     "child_ids"
    t.text     "result_rows"
  end

  add_index "searches", ["creator_id", "group_id"], :name => "index_searches_on_creator_id_and_group_id"

  create_table "stored_values", :force => true do |t|
    t.string   "key"
    t.string   "value"
    t.integer  "storable_id"
    t.string   "storable_type"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "access_level"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
