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

ActiveRecord::Schema.define(:version => 20100421174307) do

  create_table "countries", :id => false, :force => true do |t|
    t.string   "id",           :limit => 36, :null => false
    t.string   "name",         :limit => 50
    t.string   "abbreviation", :limit => 10
    t.text     "taxes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "countries", ["id"], :name => "index_countries_on_id"

  create_table "currencies", :id => false, :force => true do |t|
    t.string   "id",         :limit => 36,  :null => false
    t.string   "name",       :limit => 100
    t.string   "symbol",     :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "currencies", ["id"], :name => "index_currencies_on_id"

  create_table "items", :id => false, :force => true do |t|
    t.string   "id",              :limit => 36,                    :null => false
    t.string   "unit_id",         :limit => 36
    t.string   "itemable_id",     :limit => 36
    t.string   "itemable_type"
    t.string   "name"
    t.string   "description"
    t.string   "type"
    t.boolean  "integer",                       :default => false
    t.boolean  "product",                       :default => false
    t.boolean  "stockable",                     :default => false
    t.boolean  "visible",                       :default => true
    t.string   "organisation_id", :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "items", ["id"], :name => "index_items_on_id"
  add_index "items", ["itemable_id"], :name => "index_items_on_itemable_id"
  add_index "items", ["itemable_type"], :name => "index_items_on_itemable_type"
  add_index "items", ["organisation_id"], :name => "index_items_on_organisation_id"
  add_index "items", ["unit_id"], :name => "index_items_on_unit_id"

  create_table "links", :id => false, :force => true do |t|
    t.string   "id",              :limit => 36, :null => false
    t.string   "organisation_id", :limit => 36
    t.string   "user_id",         :limit => 36
    t.string   "role"
    t.string   "settings"
    t.boolean  "creator"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "links", ["id"], :name => "index_links_on_id"
  add_index "links", ["organisation_id"], :name => "index_links_on_organisation_id"
  add_index "links", ["user_id"], :name => "index_links_on_user_id"

  create_table "organisations", :id => false, :force => true do |t|
    t.string   "id",          :limit => 36,  :null => false
    t.string   "country_id",  :limit => 36
    t.string   "currency_id", :limit => 36
    t.string   "name",        :limit => 100
    t.string   "address"
    t.string   "address_alt"
    t.string   "phone",       :limit => 20
    t.string   "phone_alt",   :limit => 20
    t.string   "mobile",      :limit => 20
    t.string   "email"
    t.string   "website"
    t.string   "user_id",     :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organisations", ["country_id"], :name => "index_organisations_on_country_id"
  add_index "organisations", ["currency_id"], :name => "index_organisations_on_currency_id"
  add_index "organisations", ["id"], :name => "index_organisations_on_id"

  create_table "taxes", :id => false, :force => true do |t|
    t.string   "id",              :limit => 36,                               :null => false
    t.string   "name"
    t.string   "abbreviation",    :limit => 10
    t.decimal  "rate",                          :precision => 5, :scale => 2
    t.string   "organisation_id", :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taxes", ["id"], :name => "index_taxes_on_id"
  add_index "taxes", ["organisation_id"], :name => "index_taxes_on_organisation_id"

  create_table "units", :id => false, :force => true do |t|
    t.string   "id",              :limit => 36,                     :null => false
    t.string   "name",            :limit => 100
    t.string   "symbol",          :limit => 20
    t.boolean  "integer",                        :default => false
    t.boolean  "visible",                        :default => true
    t.string   "organisation_id", :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "units", ["id"], :name => "index_units_on_id"
  add_index "units", ["organisation_id"], :name => "index_units_on_organisation_id"

  create_table "users", :id => false, :force => true do |t|
    t.string   "id",                   :limit => 36,                  :null => false
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
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
    t.string   "first_name",           :limit => 80
    t.string   "last_name",            :limit => 80
    t.string   "phone",                :limit => 20
    t.string   "mobile",               :limit => 20
    t.string   "website",              :limit => 200
    t.string   "account_type",         :limit => 15
    t.string   "description"
  end

  add_index "users", ["first_name"], :name => "index_users_on_first_name"
  add_index "users", ["id"], :name => "index_users_on_id"
  add_index "users", ["last_name"], :name => "index_users_on_last_name"

end
