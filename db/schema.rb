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

ActiveRecord::Schema.define(:version => 20130115020409) do

  create_table "account_ledgers", :force => true do |t|
    t.string   "reference"
    t.string   "currency"
    t.integer  "account_id"
    t.decimal  "account_balance",                  :precision => 14, :scale => 2, :default => 0.0
    t.integer  "account_to_id"
    t.decimal  "account_to_balance",               :precision => 14, :scale => 2, :default => 0.0
    t.datetime "date"
    t.string   "operation",          :limit => 20
    t.boolean  "conciliation",                                                    :default => true
    t.decimal  "amount",                           :precision => 14, :scale => 2, :default => 0.0
    t.decimal  "exchange_rate",                    :precision => 14, :scale => 4, :default => 1.0
    t.string   "description"
    t.integer  "creator_id"
    t.integer  "approver_id"
    t.datetime "approver_datetime"
    t.integer  "nuller_id"
    t.datetime "nuller_datetime"
    t.boolean  "active",                                                          :default => true
    t.boolean  "inverse",                                                         :default => false
    t.boolean  "has_error",                                                       :default => false
    t.string   "error_messages"
    t.integer  "project_id"
    t.datetime "created_at",                                                                         :null => false
    t.datetime "updated_at",                                                                         :null => false
  end

  add_index "account_ledgers", ["account_id"], :name => "index_account_ledgers_on_account_id"
  add_index "account_ledgers", ["account_to_id"], :name => "index_account_ledgers_on_account_to_id"
  add_index "account_ledgers", ["active"], :name => "index_account_ledgers_on_active"
  add_index "account_ledgers", ["conciliation"], :name => "index_account_ledgers_on_conciliation"
  add_index "account_ledgers", ["currency"], :name => "index_account_ledgers_on_currency"
  add_index "account_ledgers", ["date"], :name => "index_account_ledgers_on_date"
  add_index "account_ledgers", ["has_error"], :name => "index_account_ledgers_on_has_error"
  add_index "account_ledgers", ["operation"], :name => "index_account_ledgers_on_operation"
  add_index "account_ledgers", ["project_id"], :name => "index_account_ledgers_on_project_id"
  add_index "account_ledgers", ["reference"], :name => "index_account_ledgers_on_reference"

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.string   "currency",       :limit => 10
    t.decimal  "exchange_rate",                 :precision => 14, :scale => 4, :default => 1.0
    t.decimal  "amount",                        :precision => 14, :scale => 2, :default => 0.0
    t.string   "type",           :limit => 30
    t.integer  "contact_id"
    t.integer  "project_id"
    t.boolean  "active",                                                       :default => true
    t.string   "description",    :limit => 500
    t.date     "date"
    t.string   "state",          :limit => 30
    t.boolean  "has_error",                                                    :default => false
    t.string   "error_messages", :limit => 400
    t.datetime "created_at",                                                                      :null => false
    t.datetime "updated_at",                                                                      :null => false
  end

  add_index "accounts", ["active"], :name => "index_accounts_on_active"
  add_index "accounts", ["amount"], :name => "index_accounts_on_amount"
  add_index "accounts", ["contact_id"], :name => "index_accounts_on_contact_id"
  add_index "accounts", ["currency"], :name => "index_accounts_on_currency"
  add_index "accounts", ["date"], :name => "index_accounts_on_date"
  add_index "accounts", ["has_error"], :name => "index_accounts_on_has_error"
  add_index "accounts", ["name"], :name => "index_accounts_on_name", :unique => true
  add_index "accounts", ["project_id"], :name => "index_accounts_on_project_id"
  add_index "accounts", ["state"], :name => "index_accounts_on_state"
  add_index "accounts", ["type"], :name => "index_accounts_on_type"

  create_table "contacts", :force => true do |t|
    t.string   "matchcode"
    t.string   "first_name",        :limit => 100
    t.string   "last_name",         :limit => 100
    t.string   "organisation_name", :limit => 100
    t.string   "address",           :limit => 250
    t.string   "phone",             :limit => 20
    t.string   "mobile",            :limit => 20
    t.string   "email",             :limit => 200
    t.string   "tax_number",        :limit => 30
    t.string   "aditional_info",    :limit => 250
    t.string   "code"
    t.string   "type"
    t.string   "position"
    t.boolean  "active",                           :default => true
    t.boolean  "staff",                            :default => false
    t.boolean  "client",                           :default => false
    t.boolean  "supplier",                         :default => false
    t.string   "money_status"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
  end

  add_index "contacts", ["active"], :name => "index_contacts_on_active"
  add_index "contacts", ["client"], :name => "index_contacts_on_client"
  add_index "contacts", ["first_name"], :name => "index_contacts_on_first_name"
  add_index "contacts", ["last_name"], :name => "index_contacts_on_last_name"
  add_index "contacts", ["matchcode"], :name => "index_contacts_on_matchcode"
  add_index "contacts", ["staff"], :name => "index_contacts_on_staff"
  add_index "contacts", ["supplier"], :name => "index_contacts_on_supplier"

  create_table "inventory_operation_details", :force => true do |t|
    t.integer  "inventory_operation_id"
    t.integer  "item_id"
    t.integer  "store_id"
    t.decimal  "quantity",               :precision => 14, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
  end

  add_index "inventory_operation_details", ["inventory_operation_id"], :name => "index_inventory_operation_details_on_inventory_operation_id"
  add_index "inventory_operation_details", ["item_id"], :name => "index_inventory_operation_details_on_item_id"
  add_index "inventory_operation_details", ["store_id"], :name => "index_inventory_operation_details_on_store_id"

  create_table "inventory_operations", :force => true do |t|
    t.integer  "contact_id"
    t.integer  "store_id"
    t.integer  "account_id"
    t.date     "date"
    t.string   "ref_number"
    t.string   "operation",       :limit => 10
    t.string   "state"
    t.string   "description"
    t.decimal  "total",                         :precision => 14, :scale => 2, :default => 0.0
    t.integer  "creator_id"
    t.integer  "transference_id"
    t.integer  "store_to_id"
    t.integer  "project_id"
    t.boolean  "has_error",                                                    :default => false
    t.string   "error_messages"
    t.datetime "created_at",                                                                      :null => false
    t.datetime "updated_at",                                                                      :null => false
  end

  add_index "inventory_operations", ["account_id"], :name => "index_inventory_operations_on_account_id"
  add_index "inventory_operations", ["contact_id"], :name => "index_inventory_operations_on_contact_id"
  add_index "inventory_operations", ["date"], :name => "index_inventory_operations_on_date"
  add_index "inventory_operations", ["has_error"], :name => "index_inventory_operations_on_has_error"
  add_index "inventory_operations", ["operation"], :name => "index_inventory_operations_on_operation"
  add_index "inventory_operations", ["project_id"], :name => "index_inventory_operations_on_project_id"
  add_index "inventory_operations", ["ref_number"], :name => "index_inventory_operations_on_ref_number"
  add_index "inventory_operations", ["state"], :name => "index_inventory_operations_on_state"
  add_index "inventory_operations", ["store_id"], :name => "index_inventory_operations_on_store_id"

  create_table "items", :force => true do |t|
    t.integer  "unit_id"
    t.decimal  "price",                      :precision => 14, :scale => 2, :default => 0.0
    t.string   "name"
    t.string   "description"
    t.string   "code",        :limit => 100
    t.boolean  "for_sale",                                                  :default => true
    t.boolean  "stockable",                                                 :default => true
    t.boolean  "active",                                                    :default => true
    t.datetime "created_at",                                                                  :null => false
    t.datetime "updated_at",                                                                  :null => false
  end

  add_index "items", ["code"], :name => "index_items_on_code"
  add_index "items", ["for_sale"], :name => "index_items_on_for_sale"
  add_index "items", ["stockable"], :name => "index_items_on_stockable"
  add_index "items", ["unit_id"], :name => "index_items_on_unit_id"

  create_table "money_stores", :force => true do |t|
    t.integer "account_id"
    t.string  "number",     :limit => 100
    t.string  "email"
    t.string  "address",    :limit => 300
    t.string  "phone",      :limit => 50
    t.string  "website"
  end

  add_index "money_stores", ["account_id"], :name => "index_money_stores_on_account_id"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.boolean  "active",      :default => true
    t.date     "date_start"
    t.date     "date_end"
    t.text     "description"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "projects", ["active"], :name => "index_projects_on_active"

  create_table "stocks", :force => true do |t|
    t.integer  "store_id"
    t.integer  "item_id"
    t.string   "state",        :limit => 20
    t.decimal  "unitary_cost",               :precision => 14, :scale => 2, :default => 0.0
    t.decimal  "quantity",                   :precision => 14, :scale => 2, :default => 0.0
    t.decimal  "minimum",                    :precision => 14, :scale => 2, :default => 0.0
    t.integer  "user_id"
    t.datetime "created_at",                                                                 :null => false
    t.datetime "updated_at",                                                                 :null => false
  end

  add_index "stocks", ["item_id"], :name => "index_stocks_on_item_id"
  add_index "stocks", ["minimum"], :name => "index_stocks_on_minimum"
  add_index "stocks", ["quantity"], :name => "index_stocks_on_quantity"
  add_index "stocks", ["state"], :name => "index_stocks_on_state"
  add_index "stocks", ["store_id"], :name => "index_stocks_on_store_id"
  add_index "stocks", ["user_id"], :name => "index_stocks_on_user_id"

  create_table "stores", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "phone"
    t.boolean  "active",      :default => true
    t.string   "description"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "transaction_details", :force => true do |t|
    t.integer  "account_id"
    t.integer  "item_id"
    t.decimal  "quantity",       :precision => 14, :scale => 2, :default => 0.0
    t.decimal  "price",          :precision => 14, :scale => 2, :default => 0.0
    t.string   "description"
    t.decimal  "discount",       :precision => 14, :scale => 2, :default => 0.0
    t.decimal  "balance",        :precision => 14, :scale => 2, :default => 0.0
    t.decimal  "original_price", :precision => 14, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
  end

  add_index "transaction_details", ["account_id"], :name => "index_transaction_details_on_account_id"
  add_index "transaction_details", ["item_id"], :name => "index_transaction_details_on_item_id"

  create_table "transaction_histories", :force => true do |t|
    t.integer  "account_id"
    t.integer  "user_id"
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "transaction_histories", ["account_id"], :name => "index_transaction_histories_on_account_id"
  add_index "transaction_histories", ["user_id"], :name => "index_transaction_histories_on_user_id"

  create_table "transactions", :force => true do |t|
    t.integer  "account_id"
    t.decimal  "balance",                          :precision => 14, :scale => 2, :default => 0.0
    t.string   "bill_number"
    t.decimal  "gross_total",                      :precision => 14, :scale => 2, :default => 0.0
    t.decimal  "original_total",                   :precision => 14, :scale => 2, :default => 0.0
    t.decimal  "balance_inventory",                :precision => 14, :scale => 2, :default => 0.0
    t.date     "payment_date"
    t.integer  "creator_id"
    t.integer  "approver_id"
    t.integer  "nuller_id"
    t.string   "null_reason",       :limit => 400
    t.datetime "approver_datetime"
    t.boolean  "delivered",                                                       :default => false
    t.boolean  "discounted",                                                      :default => false
    t.boolean  "devolution",                                                      :default => false
    t.datetime "created_at",                                                                         :null => false
    t.datetime "updated_at",                                                                         :null => false
  end

  add_index "transactions", ["account_id"], :name => "index_transactions_on_account_id"
  add_index "transactions", ["bill_number"], :name => "index_transactions_on_bill_number"
  add_index "transactions", ["delivered"], :name => "index_transactions_on_delivered"
  add_index "transactions", ["devolution"], :name => "index_transactions_on_devolution"
  add_index "transactions", ["discounted"], :name => "index_transactions_on_discounted"
  add_index "transactions", ["payment_date"], :name => "index_transactions_on_payment_date"

  create_table "units", :force => true do |t|
    t.string   "name",       :limit => 100
    t.string   "symbol",     :limit => 20
    t.boolean  "integer",                   :default => false
    t.boolean  "visible",                   :default => true
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  create_table "user_changes", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.string   "user_changeable_type"
    t.integer  "user_changeable_id"
    t.text     "description"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "user_changes", ["user_changeable_id"], :name => "index_user_changes_on_user_changeable_id"
  add_index "user_changes", ["user_changeable_type"], :name => "index_user_changes_on_user_changeable_type"
  add_index "user_changes", ["user_id"], :name => "index_user_changes_on_user_id"

end
