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

ActiveRecord::Schema.define(:version => 20120517130511) do

  create_table "account_balances", :force => true do |t|
    t.integer  "user_id"
    t.integer  "contact_id"
    t.integer  "account_id"
    t.integer  "currency_id"
    t.decimal  "amount",      :precision => 14, :scale => 4
    t.decimal  "old_amount",  :precision => 14, :scale => 2
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "account_balances", ["account_id"], :name => "index_account_balances_on_account_id"
  add_index "account_balances", ["contact_id"], :name => "index_account_balances_on_contact_id"
  add_index "account_balances", ["currency_id"], :name => "index_account_balances_on_currency_id"
  add_index "account_balances", ["user_id"], :name => "index_account_balances_on_user_id"

  create_table "account_ledger_details", :force => true do |t|
    t.integer  "account_id"
    t.integer  "account_ledger_id"
    t.integer  "currency_id"
    t.integer  "related_id"
    t.decimal  "amount",                          :precision => 14, :scale => 2
    t.decimal  "exchange_rate",                   :precision => 14, :scale => 4
    t.string   "description"
    t.boolean  "active",                                                         :default => true
    t.string   "state",             :limit => 20
    t.datetime "created_at",                                                                       :null => false
    t.datetime "updated_at",                                                                       :null => false
  end

  add_index "account_ledger_details", ["account_id"], :name => "index_account_ledger_details_on_account_id"
  add_index "account_ledger_details", ["account_ledger_id"], :name => "index_account_ledger_details_on_account_ledger_id"
  add_index "account_ledger_details", ["active"], :name => "index_account_ledger_details_on_active"
  add_index "account_ledger_details", ["currency_id"], :name => "index_account_ledger_details_on_currency_id"
  add_index "account_ledger_details", ["related_id"], :name => "index_account_ledger_details_on_related_id"
  add_index "account_ledger_details", ["state"], :name => "index_account_ledger_details_on_state"

  create_table "account_ledgers", :force => true do |t|
    t.string   "reference"
    t.integer  "currency_id"
    t.integer  "account_id"
    t.integer  "to_id"
    t.date     "date"
    t.string   "operation",           :limit => 20
    t.boolean  "conciliation",                                                     :default => true
    t.decimal  "amount",                            :precision => 14, :scale => 2
    t.decimal  "exchange_rate",                     :precision => 14, :scale => 4
    t.decimal  "interests_penalties",               :precision => 14, :scale => 2, :default => 0.0
    t.string   "description"
    t.integer  "transaction_id"
    t.integer  "creator_id"
    t.integer  "approver_id"
    t.datetime "approver_datetime"
    t.integer  "nuller_id"
    t.datetime "nuller_datetime"
    t.boolean  "active",                                                           :default => true
    t.datetime "created_at",                                                                           :null => false
    t.datetime "updated_at",                                                                           :null => false
    t.decimal  "account_balance",                   :precision => 14, :scale => 2
    t.decimal  "to_balance",                        :precision => 14, :scale => 2
    t.integer  "contact_id"
    t.integer  "staff_id"
    t.date     "payment_date"
    t.boolean  "inverse",                                                          :default => false
    t.integer  "project_id"
    t.string   "transaction_type",    :limit => 30
    t.string   "status",                                                           :default => "none"
  end

  add_index "account_ledgers", ["account_id"], :name => "index_account_ledgers_on_account_id"
  add_index "account_ledgers", ["active"], :name => "index_account_ledgers_on_active"
  add_index "account_ledgers", ["approver_id"], :name => "index_account_ledgers_on_approver_id"
  add_index "account_ledgers", ["conciliation"], :name => "index_account_ledgers_on_conciliation"
  add_index "account_ledgers", ["contact_id"], :name => "index_account_ledgers_on_contact_id"
  add_index "account_ledgers", ["created_at"], :name => "index_account_ledgers_on_created_at"
  add_index "account_ledgers", ["creator_id"], :name => "index_account_ledgers_on_creator_id"
  add_index "account_ledgers", ["currency_id"], :name => "index_account_ledgers_on_currency_id"
  add_index "account_ledgers", ["date"], :name => "index_account_ledgers_on_date"
  add_index "account_ledgers", ["inverse"], :name => "index_account_ledgers_on_inverse"
  add_index "account_ledgers", ["nuller_id"], :name => "index_account_ledgers_on_nuller_id"
  add_index "account_ledgers", ["operation"], :name => "index_account_ledgers_on_operation"
  add_index "account_ledgers", ["project_id"], :name => "index_account_ledgers_on_project_id"
  add_index "account_ledgers", ["reference"], :name => "index_account_ledgers_on_reference"
  add_index "account_ledgers", ["staff_id"], :name => "index_account_ledgers_on_staff_id"
  add_index "account_ledgers", ["status"], :name => "index_account_ledgers_on_status"
  add_index "account_ledgers", ["to_id"], :name => "index_account_ledgers_on_to_id"
  add_index "account_ledgers", ["transaction_id"], :name => "index_account_ledgers_on_transaction_id"
  add_index "account_ledgers", ["transaction_type"], :name => "index_account_ledgers_on_transaction_type"

  create_table "account_types", :force => true do |t|
    t.string   "name"
    t.string   "number"
    t.string   "account_number"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "account_types", ["account_number"], :name => "index_account_types_on_account_number"

  create_table "accounts", :force => true do |t|
    t.integer  "currency_id"
    t.integer  "account_type_id"
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
  end

  add_index "accounts", ["account_type_id"], :name => "index_accounts_on_account_type_id"
  add_index "accounts", ["accountable_id"], :name => "index_accounts_on_accountable_id"
  add_index "accounts", ["accountable_type"], :name => "index_accounts_on_accountable_type"
  add_index "accounts", ["amount"], :name => "index_accounts_on_amount"
  add_index "accounts", ["currency_id"], :name => "index_accounts_on_currency_id"
  add_index "accounts", ["original_type"], :name => "index_accounts_on_original_type"
  add_index "accounts", ["type"], :name => "index_accounts_on_type"

  create_table "client_accounts", :force => true do |t|
    t.string   "name"
    t.integer  "users"
    t.integer  "agencies"
    t.boolean  "branding"
    t.integer  "disk_space"
    t.string   "backup"
    t.integer  "stored_backups"
    t.boolean  "api"
    t.boolean  "report"
    t.boolean  "third_party_apps"
    t.integer  "free_days"
    t.boolean  "email"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

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
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
  end

  add_index "contacts", ["first_name"], :name => "index_contacts_on_first_name"
  add_index "contacts", ["last_name"], :name => "index_contacts_on_last_name"
  add_index "contacts", ["matchcode"], :name => "index_contacts_on_matchcode"
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
    t.integer  "store_id"
    t.integer  "transaction_id"
    t.date     "date"
    t.string   "ref_number"
    t.string   "operation",       :limit => 10
    t.string   "state"
    t.string   "description"
    t.decimal  "total",                         :precision => 14, :scale => 2
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
    t.integer  "contact_id"
    t.integer  "creator_id"
    t.integer  "transference_id"
    t.integer  "store_to_id"
    t.integer  "project_id"
  end

  add_index "inventory_operations", ["contact_id"], :name => "index_inventory_operations_on_contact_id"
  add_index "inventory_operations", ["creator_id"], :name => "index_inventory_operations_on_creator_id"
  add_index "inventory_operations", ["date"], :name => "index_inventory_operations_on_date"
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
    t.decimal  "price",                       :precision => 14, :scale => 2
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
    t.boolean  "for_sale",                                                   :default => false
  end

  add_index "items", ["code"], :name => "index_items_on_code"
  add_index "items", ["ctype"], :name => "index_items_on_ctype"
  add_index "items", ["for_sale"], :name => "index_items_on_for_sale"
  add_index "items", ["stockable"], :name => "index_items_on_stockable"
  add_index "items", ["type"], :name => "index_items_on_type"
  add_index "items", ["unit_id"], :name => "index_items_on_unit_id"

  create_table "money_stores", :force => true do |t|
    t.integer  "currency_id"
    t.string   "type",        :limit => 30
    t.string   "name",        :limit => 100
    t.string   "number",      :limit => 30
    t.string   "address"
    t.string   "website"
    t.string   "phone"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "money_stores", ["currency_id"], :name => "index_money_stores_on_currency_id"
  add_index "money_stores", ["name"], :name => "index_money_stores_on_name"
  add_index "money_stores", ["type"], :name => "index_money_stores_on_type"

  create_table "pay_plans", :force => true do |t|
    t.integer  "transaction_id"
    t.integer  "currency_id"
    t.string   "cur"
    t.decimal  "amount",                            :precision => 14, :scale => 2
    t.decimal  "interests_penalties",               :precision => 14, :scale => 2
    t.date     "payment_date"
    t.date     "alert_date"
    t.boolean  "email",                                                            :default => true
    t.string   "ctype",               :limit => 20
    t.string   "description"
    t.boolean  "paid",                                                             :default => false
    t.string   "operation",           :limit => 20
    t.datetime "created_at",                                                                          :null => false
    t.datetime "updated_at",                                                                          :null => false
    t.integer  "project_id"
  end

  add_index "pay_plans", ["ctype"], :name => "index_pay_plans_on_ctype"
  add_index "pay_plans", ["operation"], :name => "index_pay_plans_on_operation"
  add_index "pay_plans", ["paid"], :name => "index_pay_plans_on_paid"
  add_index "pay_plans", ["payment_date"], :name => "index_pay_plans_on_payment_date"
  add_index "pay_plans", ["project_id"], :name => "index_pay_plans_on_project_id"
  add_index "pay_plans", ["transaction_id"], :name => "index_pay_plans_on_transaction_id"

  create_table "payments", :force => true do |t|
    t.integer  "transaction_id"
    t.string   "ctype"
    t.date     "date"
    t.decimal  "amount",                            :precision => 14, :scale => 2
    t.decimal  "interests_penalties",               :precision => 14, :scale => 2
    t.string   "description"
    t.integer  "account_id"
    t.integer  "account_ledger_id"
    t.integer  "contact_id"
    t.boolean  "active",                                                           :default => true
    t.string   "state",               :limit => 20
    t.decimal  "exchange_rate",                     :precision => 14, :scale => 4
    t.datetime "created_at",                                                                         :null => false
    t.datetime "updated_at",                                                                         :null => false
  end

  add_index "payments", ["account_id"], :name => "index_payments_on_account_id"
  add_index "payments", ["account_ledger_id"], :name => "index_payments_on_account_ledger_id"
  add_index "payments", ["contact_id"], :name => "index_payments_on_contact_id"
  add_index "payments", ["ctype"], :name => "index_payments_on_ctype"
  add_index "payments", ["date"], :name => "index_payments_on_date"
  add_index "payments", ["transaction_id"], :name => "index_payments_on_transaction_id"

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

  create_table "taxes", :force => true do |t|
    t.string   "name"
    t.string   "abbreviation", :limit => 10
    t.decimal  "rate",                       :precision => 5, :scale => 2
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
  end

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
    t.decimal  "quantity",                     :precision => 14, :scale => 2
    t.decimal  "price",                        :precision => 14, :scale => 2
    t.string   "description"
    t.string   "ctype",          :limit => 30
    t.decimal  "discount",                     :precision => 14, :scale => 2
    t.decimal  "balance",                      :precision => 14, :scale => 2
    t.decimal  "original_price",               :precision => 14, :scale => 2
    t.datetime "created_at",                                                                   :null => false
    t.datetime "updated_at",                                                                   :null => false
    t.decimal  "delivered",                    :precision => 14, :scale => 2, :default => 0.0
  end

  add_index "transaction_details", ["ctype"], :name => "index_transaction_details_on_ctype"
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
    t.integer  "account_id"
    t.string   "type",                :limit => 20
    t.decimal  "total",                              :precision => 14, :scale => 2
    t.decimal  "balance",                            :precision => 14, :scale => 2
    t.decimal  "tax_percent",                        :precision => 5,  :scale => 2
    t.boolean  "active",                                                            :default => true
    t.string   "description"
    t.string   "state",               :limit => 20
    t.date     "date"
    t.string   "ref_number"
    t.string   "bill_number"
    t.integer  "currency_id"
    t.decimal  "exchange_rate",                      :precision => 14, :scale => 4
    t.integer  "project_id"
    t.decimal  "discount",                           :precision => 5,  :scale => 2
    t.decimal  "gross_total",                        :precision => 14, :scale => 2
    t.boolean  "cash",                                                              :default => true
    t.date     "payment_date"
    t.decimal  "balance_inventory",                  :precision => 14, :scale => 2
    t.integer  "creator_id"
    t.integer  "approver_id"
    t.datetime "approver_datetime"
    t.string   "approver_reason"
    t.integer  "creditor_id"
    t.string   "credit_reference"
    t.datetime "credit_datetime"
    t.string   "credit_description",  :limit => 500
    t.datetime "created_at",                                                                           :null => false
    t.datetime "updated_at",                                                                           :null => false
    t.boolean  "deliver",                                                           :default => false
    t.datetime "deliver_datetime"
    t.integer  "deliver_approver_id"
    t.string   "deliver_reason"
    t.integer  "nuller_id"
    t.datetime "nuller_datetime"
    t.integer  "contact_id"
    t.boolean  "delivered",                                                         :default => false
    t.decimal  "original_total",                     :precision => 14, :scale => 2
    t.boolean  "discounted",                                                        :default => false
    t.integer  "modified_by"
    t.boolean  "fact",                                                              :default => true
    t.boolean  "devolution",                                                        :default => false
  end

  add_index "transactions", ["account_id"], :name => "index_transactions_on_account_id"
  add_index "transactions", ["active"], :name => "index_transactions_on_active"
  add_index "transactions", ["balance_inventory"], :name => "index_transactions_on_balance_inventory"
  add_index "transactions", ["cash"], :name => "index_transactions_on_cash"
  add_index "transactions", ["contact_id"], :name => "index_transactions_on_contact_id"
  add_index "transactions", ["created_at"], :name => "index_transactions_on_created_at"
  add_index "transactions", ["creditor_id"], :name => "index_transactions_on_creditor_id"
  add_index "transactions", ["currency_id"], :name => "index_transactions_on_currency_id"
  add_index "transactions", ["date"], :name => "index_transactions_on_date"
  add_index "transactions", ["deliver"], :name => "index_transactions_on_deliver"
  add_index "transactions", ["deliver_approver_id"], :name => "index_transactions_on_deliver_approver_id"
  add_index "transactions", ["delivered"], :name => "index_transactions_on_delivered"
  add_index "transactions", ["devolution"], :name => "index_transactions_on_devolution"
  add_index "transactions", ["discounted"], :name => "index_transactions_on_discounted"
  add_index "transactions", ["fact"], :name => "index_transactions_on_fact"
  add_index "transactions", ["modified_by"], :name => "index_transactions_on_modified_by"
  add_index "transactions", ["nuller_id"], :name => "index_transactions_on_nuller_id"
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

end
