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

ActiveRecord::Schema.define(:version => 20130109191526) do

  create_table "account_ledgers", :force => true do |t|
    t.string   "reference"
    t.integer  "account_id"
    t.integer  "to_id"
    t.integer  "contact_id"
    t.datetime "date"
    t.string   "operation",         :limit => 20
    t.boolean  "conciliation",                                                   :default => true
    t.decimal  "amount",                          :precision => 14, :scale => 2
    t.decimal  "exchange_rate",                   :precision => 14, :scale => 4
    t.string   "description"
    t.integer  "transaction_id"
    t.integer  "creator_id"
    t.integer  "approver_id"
    t.datetime "approver_datetime"
    t.integer  "nuller_id"
    t.datetime "nuller_datetime"
    t.boolean  "active",                                                         :default => true
    t.boolean  "has_error",                                                      :default => false
    t.string   "error_messages"
    t.datetime "created_at",                                                                         :null => false
    t.datetime "updated_at",                                                                         :null => false
    t.decimal  "account_balance",                 :precision => 14, :scale => 2
    t.decimal  "to_balance",                      :precision => 14, :scale => 2
    t.date     "payment_date"
    t.boolean  "inverse",                                                        :default => false
    t.integer  "project_id"
    t.string   "transaction_type",  :limit => 30
    t.string   "status",                                                         :default => "none"
    t.string   "currency",          :limit => 10
  end

  add_index "account_ledgers", ["account_id"], :name => "index_account_ledgers_on_account_id"
  add_index "account_ledgers", ["active"], :name => "index_account_ledgers_on_active"
  add_index "account_ledgers", ["approver_id"], :name => "index_account_ledgers_on_approver_id"
  add_index "account_ledgers", ["conciliation"], :name => "index_account_ledgers_on_conciliation"
  add_index "account_ledgers", ["contact_id"], :name => "index_account_ledgers_on_contact_id"
  add_index "account_ledgers", ["created_at"], :name => "index_account_ledgers_on_created_at"
  add_index "account_ledgers", ["creator_id"], :name => "index_account_ledgers_on_creator_id"
  add_index "account_ledgers", ["currency"], :name => "index_account_ledgers_on_currency"
  add_index "account_ledgers", ["date"], :name => "index_account_ledgers_on_date"
  add_index "account_ledgers", ["has_error"], :name => "index_account_ledgers_on_has_error"
  add_index "account_ledgers", ["inverse"], :name => "index_account_ledgers_on_inverse"
  add_index "account_ledgers", ["nuller_id"], :name => "index_account_ledgers_on_nuller_id"
  add_index "account_ledgers", ["operation"], :name => "index_account_ledgers_on_operation"
  add_index "account_ledgers", ["project_id"], :name => "index_account_ledgers_on_project_id"
  add_index "account_ledgers", ["reference"], :name => "index_account_ledgers_on_reference"
  add_index "account_ledgers", ["status"], :name => "index_account_ledgers_on_status"
  add_index "account_ledgers", ["to_id"], :name => "index_account_ledgers_on_to_id"
  add_index "account_ledgers", ["transaction_id"], :name => "index_account_ledgers_on_transaction_id"
  add_index "account_ledgers", ["transaction_type"], :name => "index_account_ledgers_on_transaction_type"

  create_table "accounts", :force => true do |t|
    t.integer  "accountable_id"
    t.string   "accountable_type"
    t.string   "original_type",    :limit => 20
    t.string   "name"
    t.string   "type",             :limit => 20
    t.decimal  "amount",                         :precision => 14, :scale => 2
    t.decimal  "initial_amount",                 :precision => 14, :scale => 2
    t.string   "number"
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
    t.string   "currency",         :limit => 10
  end

  add_index "accounts", ["accountable_id"], :name => "index_accounts_on_accountable_id"
  add_index "accounts", ["accountable_type"], :name => "index_accounts_on_accountable_type"
  add_index "accounts", ["amount"], :name => "index_accounts_on_amount"
  add_index "accounts", ["currency"], :name => "index_accounts_on_currency"
  add_index "accounts", ["original_type"], :name => "index_accounts_on_original_type"
  add_index "accounts", ["type"], :name => "index_accounts_on_type"

  create_table "contacts", :force => true do |t|
    t.string   "matchcode"
    t.string   "first_name",        :limit => 100
    t.string   "organisation_name", :limit => 100
    t.string   "address",           :limit => 250
    t.string   "address_alt",       :limit => 250
    t.string   "phone",             :limit => 20
    t.string   "mobile",            :limit => 20
    t.string   "email",             :limit => 200
    t.string   "tax_number",        :limit => 30
    t.string   "aditional_info",    :limit => 250
    t.string   "code"
    t.string   "type"
    t.string   "last_name",         :limit => 100
    t.string   "position"
    t.boolean  "active",                           :default => true
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.boolean  "client",                           :default => false
    t.boolean  "supplier",                         :default => false
  end

  add_index "contacts", ["client"], :name => "index_contacts_on_client"
  add_index "contacts", ["first_name"], :name => "index_contacts_on_first_name"
  add_index "contacts", ["last_name"], :name => "index_contacts_on_last_name"
  add_index "contacts", ["matchcode"], :name => "index_contacts_on_matchcode"
  add_index "contacts", ["supplier"], :name => "index_contacts_on_supplier"
  add_index "contacts", ["type"], :name => "index_contacts_on_type"

  create_table "inventory_operation_details", :force => true do |t|
    t.integer  "inventory_operation_id"
    t.integer  "item_id"
    t.decimal  "quantity",                             :precision => 14, :scale => 2
    t.decimal  "unitary_cost",                         :precision => 14, :scale => 2
    t.datetime "created_at",                                                          :null => false
    t.datetime "updated_at",                                                          :null => false
    t.integer  "store_id"
    t.integer  "contact_id"
    t.integer  "transaction_id"
    t.string   "operation",              :limit => 10
  end

  add_index "inventory_operation_details", ["contact_id"], :name => "index_inventory_operation_details_on_contact_id"
  add_index "inventory_operation_details", ["inventory_operation_id"], :name => "index_inventory_operation_details_on_inventory_operation_id"
  add_index "inventory_operation_details", ["item_id"], :name => "index_inventory_operation_details_on_item_id"
  add_index "inventory_operation_details", ["operation"], :name => "index_inventory_operation_details_on_operation"
  add_index "inventory_operation_details", ["store_id"], :name => "index_inventory_operation_details_on_store_id"
  add_index "inventory_operation_details", ["transaction_id"], :name => "index_inventory_operation_details_on_transaction_id"

  create_table "inventory_operations", :force => true do |t|
    t.integer  "contact_id"
    t.integer  "store_id"
    t.integer  "transaction_id"
    t.date     "date"
    t.string   "ref_number"
    t.string   "operation",       :limit => 10
    t.string   "state"
    t.string   "description"
    t.decimal  "total",                         :precision => 14, :scale => 2
    t.boolean  "has_error",                                                    :default => false
    t.string   "error_messages"
    t.datetime "created_at",                                                                      :null => false
    t.datetime "updated_at",                                                                      :null => false
    t.integer  "creator_id"
    t.integer  "transference_id"
    t.integer  "store_to_id"
    t.integer  "project_id"
  end

  add_index "inventory_operations", ["contact_id"], :name => "index_inventory_operations_on_contact_id"
  add_index "inventory_operations", ["creator_id"], :name => "index_inventory_operations_on_creator_id"
  add_index "inventory_operations", ["date"], :name => "index_inventory_operations_on_date"
  add_index "inventory_operations", ["has_error"], :name => "index_inventory_operations_on_has_error"
  add_index "inventory_operations", ["operation"], :name => "index_inventory_operations_on_operation"
  add_index "inventory_operations", ["project_id"], :name => "index_inventory_operations_on_project_id"
  add_index "inventory_operations", ["ref_number"], :name => "index_inventory_operations_on_ref_number"
  add_index "inventory_operations", ["state"], :name => "index_inventory_operations_on_state"
  add_index "inventory_operations", ["store_id"], :name => "index_inventory_operations_on_store_id"
  add_index "inventory_operations", ["transaction_id"], :name => "index_inventory_operations_on_transaction_id"
  add_index "inventory_operations", ["transference_id"], :name => "index_inventory_operations_on_transference_id"

  create_table "items", :force => true do |t|
    t.integer  "unit_id"
    t.decimal  "unitary_cost",                :precision => 14, :scale => 2
    t.decimal  "price",                       :precision => 14, :scale => 2, :default => 0.0
    t.string   "name"
    t.string   "description"
    t.string   "code",         :limit => 100
    t.boolean  "integer",                                                    :default => false
    t.boolean  "stockable",                                                  :default => false
    t.boolean  "active",                                                     :default => true
    t.string   "discount"
    t.string   "ctype",        :limit => 20
    t.string   "type"
    t.string   "un_name"
    t.string   "un_symbol",    :limit => 10
    t.datetime "created_at",                                                                    :null => false
    t.datetime "updated_at",                                                                    :null => false
    t.boolean  "for_sale",                                                   :default => true
  end

  add_index "items", ["code"], :name => "index_items_on_code"
  add_index "items", ["ctype"], :name => "index_items_on_ctype"
  add_index "items", ["for_sale"], :name => "index_items_on_for_sale"
  add_index "items", ["stockable"], :name => "index_items_on_stockable"
  add_index "items", ["type"], :name => "index_items_on_type"
  add_index "items", ["unit_id"], :name => "index_items_on_unit_id"

  create_table "money_stores", :force => true do |t|
    t.string   "type",       :limit => 30
    t.string   "name",       :limit => 100
    t.string   "number",     :limit => 30
    t.string   "address"
    t.string   "website"
    t.string   "phone"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "currency",   :limit => 10
  end

  add_index "money_stores", ["currency"], :name => "index_money_stores_on_currency"
  add_index "money_stores", ["name"], :name => "index_money_stores_on_name"
  add_index "money_stores", ["type"], :name => "index_money_stores_on_type"

  create_table "prices", :force => true do |t|
    t.integer  "item_id"
    t.decimal  "unitary_cost", :precision => 14, :scale => 2
    t.decimal  "price",        :precision => 14, :scale => 2
    t.string   "discount"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "prices", ["item_id"], :name => "index_prices_on_item_id"

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
    t.decimal  "unitary_cost",               :precision => 14, :scale => 2
    t.decimal  "quantity",                   :precision => 14, :scale => 2
    t.decimal  "minimum",                    :precision => 14, :scale => 2
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
    t.integer  "user_id"
  end

  add_index "stocks", ["item_id"], :name => "index_stocks_on_item_id"
  add_index "stocks", ["minimum"], :name => "index_stocks_on_minimum"
  add_index "stocks", ["quantity"], :name => "index_stocks_on_quantity"
  add_index "stocks", ["state"], :name => "index_stocks_on_state"
  add_index "stocks", ["store_id"], :name => "index_stocks_on_store_id"
  add_index "stocks", ["updated_at"], :name => "index_stocks_on_updated_at"
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
    t.integer  "transaction_id"
    t.integer  "item_id"
    t.decimal  "quantity",                     :precision => 14, :scale => 2, :default => 0.0
    t.decimal  "price",                        :precision => 14, :scale => 2, :default => 0.0
    t.string   "description"
    t.string   "ctype",          :limit => 30
    t.decimal  "discount",                     :precision => 14, :scale => 2
    t.decimal  "balance",                      :precision => 14, :scale => 2
    t.decimal  "original_price",               :precision => 14, :scale => 2
    t.datetime "created_at",                                                                   :null => false
    t.datetime "updated_at",                                                                   :null => false
    t.decimal  "delivered",                    :precision => 14, :scale => 2, :default => 0.0
    t.string   "currency",       :limit => 10
  end

  add_index "transaction_details", ["ctype"], :name => "index_transaction_details_on_ctype"
  add_index "transaction_details", ["currency"], :name => "index_transaction_details_on_currency"
  add_index "transaction_details", ["item_id"], :name => "index_transaction_details_on_item_id"
  add_index "transaction_details", ["transaction_id"], :name => "index_transaction_details_on_transaction_id"

  create_table "transaction_histories", :force => true do |t|
    t.integer  "transaction_id"
    t.integer  "user_id"
    t.text     "data"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "transaction_histories", ["transaction_id"], :name => "index_transaction_histories_on_transaction_id"
  add_index "transaction_histories", ["user_id"], :name => "index_transaction_histories_on_user_id"

  create_table "transactions", :force => true do |t|
    t.integer  "contact_id"
    t.string   "type",              :limit => 20
    t.decimal  "total",                           :precision => 14, :scale => 2
    t.decimal  "balance",                         :precision => 14, :scale => 2
    t.decimal  "tax_percent",                     :precision => 5,  :scale => 2
    t.boolean  "active",                                                         :default => true
    t.string   "description"
    t.string   "state",             :limit => 20
    t.date     "date"
    t.string   "ref_number"
    t.string   "bill_number"
    t.decimal  "exchange_rate",                   :precision => 14, :scale => 4, :default => 1.0
    t.integer  "project_id"
    t.decimal  "discount",                        :precision => 5,  :scale => 2, :default => 0.0
    t.decimal  "gross_total",                     :precision => 14, :scale => 2, :default => 0.0
    t.boolean  "cash",                                                           :default => true
    t.date     "payment_date"
    t.decimal  "balance_inventory",               :precision => 14, :scale => 2
    t.boolean  "has_error",                                                      :default => false
    t.string   "error_messages"
    t.datetime "created_at",                                                                        :null => false
    t.datetime "updated_at",                                                                        :null => false
    t.boolean  "delivered",                                                      :default => false
    t.decimal  "original_total",                  :precision => 14, :scale => 2
    t.boolean  "discounted",                                                     :default => false
    t.integer  "modified_by"
    t.boolean  "fact",                                                           :default => true
    t.boolean  "devolution",                                                     :default => false
    t.string   "currency",          :limit => 10
  end

  add_index "transactions", ["active"], :name => "index_transactions_on_active"
  add_index "transactions", ["balance_inventory"], :name => "index_transactions_on_balance_inventory"
  add_index "transactions", ["cash"], :name => "index_transactions_on_cash"
  add_index "transactions", ["contact_id"], :name => "index_transactions_on_contact_id"
  add_index "transactions", ["created_at"], :name => "index_transactions_on_created_at"
  add_index "transactions", ["currency"], :name => "index_transactions_on_currency"
  add_index "transactions", ["date"], :name => "index_transactions_on_date"
  add_index "transactions", ["delivered"], :name => "index_transactions_on_delivered"
  add_index "transactions", ["devolution"], :name => "index_transactions_on_devolution"
  add_index "transactions", ["discounted"], :name => "index_transactions_on_discounted"
  add_index "transactions", ["fact"], :name => "index_transactions_on_fact"
  add_index "transactions", ["has_error"], :name => "index_transactions_on_has_error"
  add_index "transactions", ["modified_by"], :name => "index_transactions_on_modified_by"
  add_index "transactions", ["payment_date"], :name => "index_transactions_on_payment_date"
  add_index "transactions", ["project_id"], :name => "index_transactions_on_project_id"
  add_index "transactions", ["ref_number"], :name => "index_transactions_on_ref_number"
  add_index "transactions", ["state"], :name => "index_transactions_on_state"

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
    t.string   "user_changeable_type"
    t.integer  "user_changeable_id"
    t.text     "description"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "user_id"
  end

  add_index "user_changes", ["user_changeable_id"], :name => "index_user_changes_on_user_changeable_id"
  add_index "user_changes", ["user_changeable_type"], :name => "index_user_changes_on_user_changeable_type"
  add_index "user_changes", ["user_id"], :name => "index_user_changes_on_user_id"

end
