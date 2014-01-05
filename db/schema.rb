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

ActiveRecord::Schema.define(version: 20140105165519) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "account_ledgers", force: true do |t|
    t.string   "reference"
    t.string   "currency"
    t.integer  "account_id"
    t.decimal  "account_balance",               precision: 14, scale: 2, default: 0.0
    t.integer  "account_to_id"
    t.decimal  "account_to_balance",            precision: 14, scale: 2, default: 0.0
    t.date     "date"
    t.string   "operation",          limit: 20
    t.decimal  "amount",                        precision: 14, scale: 2, default: 0.0
    t.decimal  "exchange_rate",                 precision: 14, scale: 4, default: 1.0
    t.string   "description"
    t.integer  "creator_id"
    t.integer  "approver_id"
    t.datetime "approver_datetime"
    t.integer  "nuller_id"
    t.datetime "nuller_datetime"
    t.boolean  "inverse",                                                default: false
    t.boolean  "has_error",                                              default: false
    t.string   "error_messages"
    t.integer  "project_id"
    t.datetime "created_at",                                                                  null: false
    t.datetime "updated_at",                                                                  null: false
    t.string   "status",             limit: 50,                          default: "approved"
    t.integer  "updater_id"
    t.string   "name"
    t.integer  "contact_id"
  end

  add_index "account_ledgers", ["account_id"], name: "index_account_ledgers_on_account_id", using: :btree
  add_index "account_ledgers", ["account_to_id"], name: "index_account_ledgers_on_account_to_id", using: :btree
  add_index "account_ledgers", ["contact_id"], name: "index_account_ledgers_on_contact_id", using: :btree
  add_index "account_ledgers", ["currency"], name: "index_account_ledgers_on_currency", using: :btree
  add_index "account_ledgers", ["date"], name: "index_account_ledgers_on_date", using: :btree
  add_index "account_ledgers", ["has_error"], name: "index_account_ledgers_on_has_error", using: :btree
  add_index "account_ledgers", ["name"], name: "index_account_ledgers_on_name", unique: true, using: :btree
  add_index "account_ledgers", ["operation"], name: "index_account_ledgers_on_operation", using: :btree
  add_index "account_ledgers", ["project_id"], name: "index_account_ledgers_on_project_id", using: :btree
  add_index "account_ledgers", ["reference"], name: "index_account_ledgers_on_reference", using: :btree
  add_index "account_ledgers", ["status"], name: "index_account_ledgers_on_status", using: :btree
  add_index "account_ledgers", ["updater_id"], name: "index_account_ledgers_on_updater_id", using: :btree

  create_table "accounts", force: true do |t|
    t.string   "name"
    t.string   "currency",       limit: 10
    t.decimal  "exchange_rate",              precision: 14, scale: 4, default: 1.0
    t.decimal  "amount",                     precision: 14, scale: 2, default: 0.0
    t.string   "type",           limit: 30
    t.integer  "contact_id"
    t.integer  "project_id"
    t.boolean  "active",                                              default: true
    t.string   "description",    limit: 500
    t.date     "date"
    t.string   "state",          limit: 30
    t.boolean  "has_error",                                           default: false
    t.string   "error_messages", limit: 400
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.integer  "tag_ids",                                             default: [],                 array: true
    t.integer  "updater_id"
    t.decimal  "tax_percentage",             precision: 5,  scale: 2, default: 0.0
    t.integer  "tax_id"
    t.decimal  "total",                      precision: 14, scale: 2, default: 0.0
    t.boolean  "tax_in_out",                                          default: false
    t.hstore   "extras"
    t.integer  "creator_id"
    t.integer  "approver_id"
    t.integer  "nuller_id"
    t.date     "due_date"
  end

  add_index "accounts", ["active"], name: "index_accounts_on_active", using: :btree
  add_index "accounts", ["amount"], name: "index_accounts_on_amount", using: :btree
  add_index "accounts", ["approver_id"], name: "index_accounts_on_approver_id", using: :btree
  add_index "accounts", ["contact_id"], name: "index_accounts_on_contact_id", using: :btree
  add_index "accounts", ["creator_id"], name: "index_accounts_on_creator_id", using: :btree
  add_index "accounts", ["currency"], name: "index_accounts_on_currency", using: :btree
  add_index "accounts", ["date"], name: "index_accounts_on_date", using: :btree
  add_index "accounts", ["due_date"], name: "index_accounts_on_due_date", using: :btree
  add_index "accounts", ["extras"], name: "index_accounts_on_extras", using: :gist
  add_index "accounts", ["has_error"], name: "index_accounts_on_has_error", using: :btree
  add_index "accounts", ["name"], name: "index_accounts_on_name", unique: true, using: :btree
  add_index "accounts", ["nuller_id"], name: "index_accounts_on_nuller_id", using: :btree
  add_index "accounts", ["project_id"], name: "index_accounts_on_project_id", using: :btree
  add_index "accounts", ["state"], name: "index_accounts_on_state", using: :btree
  add_index "accounts", ["tag_ids"], name: "index_accounts_on_tag_ids", using: :gin
  add_index "accounts", ["tax_id"], name: "index_accounts_on_tax_id", using: :btree
  add_index "accounts", ["tax_in_out"], name: "index_accounts_on_tax_in_out", using: :btree
  add_index "accounts", ["type"], name: "index_accounts_on_type", using: :btree
  add_index "accounts", ["updater_id"], name: "index_accounts_on_updater_id", using: :btree

  create_table "contacts", force: true do |t|
    t.string   "matchcode"
    t.string   "first_name",        limit: 100
    t.string   "last_name",         limit: 100
    t.string   "organisation_name", limit: 100
    t.string   "address",           limit: 250
    t.string   "phone",             limit: 40
    t.string   "mobile",            limit: 40
    t.string   "email",             limit: 200
    t.string   "tax_number",        limit: 30
    t.string   "aditional_info",    limit: 250
    t.string   "code"
    t.string   "type"
    t.string   "position"
    t.boolean  "active",                        default: true
    t.boolean  "staff",                         default: false
    t.boolean  "client",                        default: false
    t.boolean  "supplier",                      default: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "incomes_status",    limit: 300, default: "{}"
    t.string   "expenses_status",   limit: 300, default: "{}"
  end

  add_index "contacts", ["active"], name: "index_contacts_on_active", using: :btree
  add_index "contacts", ["client"], name: "index_contacts_on_client", using: :btree
  add_index "contacts", ["first_name"], name: "index_contacts_on_first_name", using: :btree
  add_index "contacts", ["last_name"], name: "index_contacts_on_last_name", using: :btree
  add_index "contacts", ["matchcode"], name: "index_contacts_on_matchcode", using: :btree
  add_index "contacts", ["staff"], name: "index_contacts_on_staff", using: :btree
  add_index "contacts", ["supplier"], name: "index_contacts_on_supplier", using: :btree

  create_table "inventories", force: true do |t|
    t.integer  "contact_id"
    t.integer  "store_id"
    t.integer  "account_id"
    t.date     "date"
    t.string   "ref_number"
    t.string   "operation",       limit: 10
    t.string   "description"
    t.decimal  "total",                      precision: 14, scale: 2, default: 0.0
    t.integer  "creator_id"
    t.integer  "transference_id"
    t.integer  "store_to_id"
    t.integer  "project_id"
    t.boolean  "has_error",                                           default: false
    t.string   "error_messages"
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.integer  "updater_id"
  end

  add_index "inventories", ["account_id"], name: "index_inventory_operations_on_account_id", using: :btree
  add_index "inventories", ["contact_id"], name: "index_inventory_operations_on_contact_id", using: :btree
  add_index "inventories", ["date"], name: "index_inventory_operations_on_date", using: :btree
  add_index "inventories", ["has_error"], name: "index_inventory_operations_on_has_error", using: :btree
  add_index "inventories", ["operation"], name: "index_inventory_operations_on_operation", using: :btree
  add_index "inventories", ["project_id"], name: "index_inventory_operations_on_project_id", using: :btree
  add_index "inventories", ["ref_number"], name: "index_inventory_operations_on_ref_number", using: :btree
  add_index "inventories", ["store_id"], name: "index_inventory_operations_on_store_id", using: :btree
  add_index "inventories", ["updater_id"], name: "index_inventories_on_updater_id", using: :btree

  create_table "inventory_details", force: true do |t|
    t.integer  "inventory_id"
    t.integer  "item_id"
    t.integer  "store_id"
    t.decimal  "quantity",     precision: 14, scale: 2, default: 0.0
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  add_index "inventory_details", ["inventory_id"], name: "index_inventory_details_on_inventory_id", using: :btree
  add_index "inventory_details", ["item_id"], name: "index_inventory_operation_details_on_item_id", using: :btree
  add_index "inventory_details", ["store_id"], name: "index_inventory_operation_details_on_store_id", using: :btree

  create_table "items", force: true do |t|
    t.integer  "unit_id"
    t.decimal  "price",                   precision: 14, scale: 2, default: 0.0
    t.string   "name"
    t.string   "description"
    t.string   "code",        limit: 100
    t.boolean  "for_sale",                                         default: true
    t.boolean  "stockable",                                        default: true
    t.boolean  "active",                                           default: true
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.decimal  "buy_price",               precision: 14, scale: 2, default: 0.0
    t.string   "unit_symbol", limit: 20
    t.string   "unit_name"
    t.integer  "tag_ids",                                          default: [],                array: true
    t.integer  "updater_id"
  end

  add_index "items", ["code"], name: "index_items_on_code", using: :btree
  add_index "items", ["for_sale"], name: "index_items_on_for_sale", using: :btree
  add_index "items", ["stockable"], name: "index_items_on_stockable", using: :btree
  add_index "items", ["tag_ids"], name: "index_items_on_tag_ids", using: :gin
  add_index "items", ["unit_id"], name: "index_items_on_unit_id", using: :btree
  add_index "items", ["updater_id"], name: "index_items_on_updater_id", using: :btree

  create_table "loan_extras", force: true do |t|
    t.integer "step",                               default: 1
    t.integer "loan_id",                                          null: false
    t.date    "due_date",                                         null: false
    t.decimal "interests", precision: 14, scale: 2, default: 0.0, null: false
  end

  add_index "loan_extras", ["loan_id"], name: "index_loan_extras_on_loan_id", unique: true, using: :btree

  create_table "money_stores", force: true do |t|
    t.integer "account_id"
    t.string  "email"
    t.string  "address",    limit: 300
    t.string  "phone",      limit: 50
    t.string  "website"
  end

  add_index "money_stores", ["account_id"], name: "index_money_stores_on_account_id", using: :btree

  create_table "projects", force: true do |t|
    t.string   "name"
    t.boolean  "active",      default: true
    t.date     "date_start"
    t.date     "date_end"
    t.text     "description"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "projects", ["active"], name: "index_projects_on_active", using: :btree

  create_table "stocks", force: true do |t|
    t.integer  "store_id"
    t.integer  "item_id"
    t.decimal  "unitary_cost", precision: 14, scale: 2, default: 0.0
    t.decimal  "quantity",     precision: 14, scale: 2, default: 0.0
    t.decimal  "minimum",      precision: 14, scale: 2, default: 0.0
    t.integer  "user_id"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.boolean  "active",                                default: true
  end

  add_index "stocks", ["active"], name: "index_stocks_on_active", using: :btree
  add_index "stocks", ["item_id"], name: "index_stocks_on_item_id", using: :btree
  add_index "stocks", ["minimum"], name: "index_stocks_on_minimum", using: :btree
  add_index "stocks", ["quantity"], name: "index_stocks_on_quantity", using: :btree
  add_index "stocks", ["store_id"], name: "index_stocks_on_store_id", using: :btree
  add_index "stocks", ["user_id"], name: "index_stocks_on_user_id", using: :btree

  create_table "stores", force: true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "phone",       limit: 40
    t.boolean  "active",                 default: true
    t.string   "description"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "tags", force: true do |t|
    t.string   "name"
    t.string   "bgcolor",    limit: 10
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "tags", ["name"], name: "index_tags_on_name", using: :btree

  create_table "taxes", force: true do |t|
    t.string   "name",        limit: 100
    t.string   "abreviation", limit: 20
    t.decimal  "percentage",              precision: 5, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transaction_details", force: true do |t|
    t.integer  "account_id"
    t.integer  "item_id"
    t.decimal  "quantity",       precision: 14, scale: 2, default: 0.0
    t.decimal  "price",          precision: 14, scale: 2, default: 0.0
    t.string   "description"
    t.decimal  "discount",       precision: 14, scale: 2, default: 0.0
    t.decimal  "balance",        precision: 14, scale: 2, default: 0.0
    t.decimal  "original_price", precision: 14, scale: 2, default: 0.0
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  add_index "transaction_details", ["account_id"], name: "index_transaction_details_on_account_id", using: :btree
  add_index "transaction_details", ["item_id"], name: "index_transaction_details_on_item_id", using: :btree

  create_table "transaction_histories", force: true do |t|
    t.integer  "account_id"
    t.integer  "user_id"
    t.text     "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "transaction_histories", ["account_id"], name: "index_transaction_histories_on_account_id", using: :btree
  add_index "transaction_histories", ["user_id"], name: "index_transaction_histories_on_user_id", using: :btree

  create_table "transactions", force: true do |t|
    t.integer  "account_id"
    t.string   "bill_number"
    t.decimal  "gross_total",                   precision: 14, scale: 2, default: 0.0
    t.decimal  "original_total",                precision: 14, scale: 2, default: 0.0
    t.decimal  "balance_inventory",             precision: 14, scale: 2, default: 0.0
    t.date     "due_date"
    t.integer  "creator_id"
    t.integer  "approver_id"
    t.integer  "nuller_id"
    t.datetime "nuller_datetime"
    t.string   "null_reason",       limit: 400
    t.datetime "approver_datetime"
    t.boolean  "delivered",                                              default: false
    t.boolean  "discounted",                                             default: false
    t.boolean  "devolution",                                             default: false
    t.datetime "created_at",                                                             null: false
    t.datetime "updated_at",                                                             null: false
    t.boolean  "no_inventory",                                           default: false
  end

  add_index "transactions", ["account_id"], name: "index_transactions_on_account_id", using: :btree
  add_index "transactions", ["bill_number"], name: "index_transactions_on_bill_number", using: :btree
  add_index "transactions", ["delivered"], name: "index_transactions_on_delivered", using: :btree
  add_index "transactions", ["devolution"], name: "index_transactions_on_devolution", using: :btree
  add_index "transactions", ["discounted"], name: "index_transactions_on_discounted", using: :btree
  add_index "transactions", ["due_date"], name: "index_transactions_on_due_date", using: :btree
  add_index "transactions", ["no_inventory"], name: "index_transactions_on_no_inventory", using: :btree

  create_table "units", force: true do |t|
    t.string   "name",       limit: 100
    t.string   "symbol",     limit: 20
    t.boolean  "integer",                default: false
    t.boolean  "visible",                default: true
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "user_changes", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.string   "user_changeable_type"
    t.integer  "user_changeable_id"
    t.text     "description"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "user_changes", ["user_changeable_id"], name: "index_user_changes_on_user_changeable_id", using: :btree
  add_index "user_changes", ["user_changeable_type"], name: "index_user_changes_on_user_changeable_type", using: :btree
  add_index "user_changes", ["user_id"], name: "index_user_changes_on_user_id", using: :btree

end
