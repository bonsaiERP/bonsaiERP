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

ActiveRecord::Schema.define(:version => 20110127181906) do

  create_table "contacts", :force => true do |t|
    t.string   "matchcode"
    t.string   "name",              :limit => 100
    t.string   "organisation_name", :limit => 100
    t.string   "address",           :limit => 250
    t.string   "address_alt",       :limit => 250
    t.string   "phone",             :limit => 20
    t.string   "mobile",            :limit => 20
    t.boolean  "client",                           :default => false
    t.boolean  "supplier",                         :default => false
    t.string   "email",             :limit => 200
    t.string   "tax_number",        :limit => 30
    t.string   "aditional_info",    :limit => 250
    t.integer  "organisation_id",                                     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contacts", ["client"], :name => "index_contacts_on_client"
  add_index "contacts", ["matchcode"], :name => "index_contacts_on_matchcode"
  add_index "contacts", ["organisation_id"], :name => "index_contacts_on_organisation_id"
  add_index "contacts", ["supplier"], :name => "index_contacts_on_supplier"

  create_table "countries", :force => true do |t|
    t.string   "name",         :limit => 50
    t.string   "abbreviation", :limit => 10
    t.text     "taxes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "currencies", :force => true do |t|
    t.string   "name",       :limit => 100
    t.string   "symbol",     :limit => 20
    t.string   "code",       :limit => 5
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "currencies_organisations", :id => false, :force => true do |t|
    t.integer "currency_id"
    t.integer "organisation_id"
  end

  add_index "currencies_organisations", ["currency_id", "organisation_id"], :name => "currencies_orgs_c_id_org_id"

  create_table "currency_rates", :force => true do |t|
    t.integer  "currency_id"
    t.decimal  "rate",            :precision => 14, :scale => 6
    t.boolean  "active",                                         :default => false
    t.integer  "organisation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "currency_rates", ["active"], :name => "index_currency_rates_on_active"
  add_index "currency_rates", ["created_at"], :name => "index_currency_rates_on_created_at"
  add_index "currency_rates", ["currency_id"], :name => "index_currency_rates_on_currency_id"
  add_index "currency_rates", ["organisation_id"], :name => "index_currency_rates_on_organisation_id"

  create_table "items", :force => true do |t|
    t.integer  "unit_id"
    t.decimal  "unitary_cost",                   :precision => 14, :scale => 2
    t.decimal  "price",                          :precision => 14, :scale => 2
    t.string   "name"
    t.string   "description"
    t.string   "code",            :limit => 100
    t.boolean  "integer",                                                       :default => false
    t.boolean  "stockable",                                                     :default => false
    t.boolean  "active",                                                        :default => true
    t.string   "discount"
    t.string   "ctype",           :limit => 20
    t.integer  "organisation_id",                                                                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "items", ["code"], :name => "index_items_on_code"
  add_index "items", ["ctype"], :name => "index_items_on_ctype"
  add_index "items", ["organisation_id"], :name => "index_items_on_organisation_id"
  add_index "items", ["unit_id"], :name => "index_items_on_unit_id"

  create_table "links", :force => true do |t|
    t.integer  "organisation_id"
    t.integer  "user_id"
    t.integer  "rol_id"
    t.string   "settings"
    t.boolean  "creator"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "links", ["organisation_id"], :name => "index_links_on_organisation_id"
  add_index "links", ["user_id"], :name => "index_links_on_user_id"

  create_table "organisations", :force => true do |t|
    t.integer  "country_id"
    t.integer  "currency_id"
    t.string   "name",        :limit => 100
    t.string   "address"
    t.string   "address_alt"
    t.string   "phone",       :limit => 20
    t.string   "phone_alt",   :limit => 20
    t.string   "mobile",      :limit => 20
    t.string   "email"
    t.string   "website"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organisations", ["country_id"], :name => "index_organisations_on_country_id"
  add_index "organisations", ["currency_id"], :name => "index_organisations_on_currency_id"

  create_table "pay_plans", :force => true do |t|
    t.integer  "organisation_id"
    t.integer  "transaction_id"
    t.integer  "currency_id"
    t.decimal  "amount",                            :precision => 14, :scale => 2
    t.decimal  "interests_penalties",               :precision => 14, :scale => 2
    t.date     "payment_date"
    t.date     "alert_date"
    t.boolean  "email"
    t.string   "ctype",               :limit => 10
    t.string   "description"
    t.boolean  "paid",                                                             :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pay_plans", ["ctype"], :name => "index_pay_plans_on_ctype"
  add_index "pay_plans", ["organisation_id"], :name => "index_pay_plans_on_organisation_id"
  add_index "pay_plans", ["paid"], :name => "index_pay_plans_on_paid"
  add_index "pay_plans", ["payment_date"], :name => "index_pay_plans_on_payment_date"
  add_index "pay_plans", ["transaction_id"], :name => "index_pay_plans_on_transaction_id"

  create_table "prices", :force => true do |t|
    t.integer  "item_id"
    t.decimal  "unitary_cost", :precision => 14, :scale => 2
    t.decimal  "price",        :precision => 14, :scale => 2
    t.string   "discount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.boolean  "active"
    t.date     "date_start"
    t.date     "date_end"
    t.integer  "organisation_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "projects", ["active"], :name => "index_projects_on_active"
  add_index "projects", ["organisation_id"], :name => "index_projects_on_organisation_id"

  create_table "stores", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "phone"
    t.boolean  "active"
    t.string   "description"
    t.integer  "organisation_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stores", ["organisation_id"], :name => "index_stores_on_organisation_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "organisation_id"
  end

  add_index "tags", ["organisation_id"], :name => "index_tags_on_organisation_id"

  create_table "taxes", :force => true do |t|
    t.string   "name"
    t.string   "abbreviation",    :limit => 10
    t.decimal  "rate",                          :precision => 5, :scale => 2
    t.integer  "organisation_id",                                             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taxes", ["organisation_id"], :name => "index_taxes_on_organisation_id"

  create_table "taxes_transactions", :id => false, :force => true do |t|
    t.integer "tax_id"
    t.integer "transaction_id"
  end

  add_index "taxes_transactions", ["tax_id", "transaction_id"], :name => "index_taxes_transactions_on_tax_id_and_transaction_id"
  add_index "taxes_transactions", ["tax_id"], :name => "index_taxes_transactions_on_tax_id"
  add_index "taxes_transactions", ["transaction_id"], :name => "index_taxes_transactions_on_transaction_id"

  create_table "transaction_details", :force => true do |t|
    t.integer  "transaction_id"
    t.integer  "item_id"
    t.integer  "currency_id"
    t.decimal  "quantity",                      :precision => 14, :scale => 2
    t.decimal  "price",                         :precision => 14, :scale => 2
    t.string   "description"
    t.decimal  "minimun",                       :precision => 14, :scale => 2
    t.decimal  "maximun",                       :precision => 14, :scale => 2
    t.string   "ctype",           :limit => 30
    t.decimal  "discount",                      :precision => 14, :scale => 2
    t.integer  "organisation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transaction_details", ["ctype"], :name => "index_transaction_details_on_ctype"
  add_index "transaction_details", ["item_id"], :name => "index_transaction_details_on_item_id"
  add_index "transaction_details", ["organisation_id"], :name => "index_transaction_details_on_organisation_id"
  add_index "transaction_details", ["transaction_id"], :name => "index_transaction_details_on_transaction_id"

  create_table "transactions", :force => true do |t|
    t.integer  "contact_id"
    t.string   "type",                   :limit => 20
    t.decimal  "total",                                :precision => 14, :scale => 2
    t.decimal  "balance",                              :precision => 14, :scale => 2
    t.decimal  "tax_percent",                          :precision => 5,  :scale => 2
    t.boolean  "active"
    t.string   "description"
    t.string   "state"
    t.date     "date"
    t.string   "ref_number"
    t.string   "bill_number"
    t.integer  "currency_id"
    t.decimal  "currency_exchange_rate",               :precision => 14, :scale => 6
    t.integer  "organisation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.decimal  "discount",                             :precision => 5,  :scale => 2
    t.decimal  "gross_total",                          :precision => 14, :scale => 2
    t.boolean  "cash",                                                                :default => true
  end

  add_index "transactions", ["active"], :name => "index_transactions_on_active"
  add_index "transactions", ["cash"], :name => "index_transactions_on_cash"
  add_index "transactions", ["contact_id"], :name => "index_transactions_on_contact_id"
  add_index "transactions", ["currency_id"], :name => "index_transactions_on_currency_id"
  add_index "transactions", ["date"], :name => "index_transactions_on_date"
  add_index "transactions", ["organisation_id"], :name => "index_transactions_on_organisation_id"
  add_index "transactions", ["project_id"], :name => "index_transactions_on_project_id"
  add_index "transactions", ["ref_number"], :name => "index_transactions_on_ref_number"

  create_table "units", :force => true do |t|
    t.string   "name",            :limit => 100
    t.string   "symbol",          :limit => 20
    t.boolean  "integer",                        :default => false
    t.boolean  "visible",                        :default => true
    t.integer  "organisation_id",                                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "units", ["organisation_id"], :name => "index_units_on_organisation_id"

  create_table "users", :force => true do |t|
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
  add_index "users", ["last_name"], :name => "index_users_on_last_name"

end
