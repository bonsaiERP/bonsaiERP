class CreateAccountLedgers < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do

      create_table :account_ledgers do |t|
        t.string   :reference
        t.string   :currency
        t.integer  :account_id
        t.decimal  :account_balance, precision: 14, scale: 2, default: 0.0
        t.integer  :account_to_id
        t.decimal  :account_to_balance, precision: 14, scale: 2, default: 0.0
        t.datetime :date
        t.string   :operation, limit: 20

        t.boolean :conciliation, default: true
        t.decimal :amount, precision: 14, scale: 2, default: 0.0
        t.decimal :exchange_rate, precision: 14, scale: 4, default: 1.0

        t.string  :description

        t.integer  :creator_id # related with created_at
        t.integer  :approver_id
        t.datetime :approver_datetime # conciliation
        t.integer  :nuller_id
        t.datetime :nuller_datetime # null
        t.boolean  :active, :default => true
        t.boolean  :inverse, :default => false

        t.boolean :has_error, default: false
        t.string  :error_messages
        t.string  :status, limit: 50, default: 'approved'

        t.integer :project_id

        t.timestamps
      end

      add_index :account_ledgers, :currency
      add_index :account_ledgers, :account_id
      add_index :account_ledgers, :account_to_id
      add_index :account_ledgers, :date
      add_index :account_ledgers, :conciliation
      add_index :account_ledgers, :operation
      add_index :account_ledgers, :reference
      add_index :account_ledgers, :active
      add_index :account_ledgers, :has_error
      add_index :account_ledgers, :project_id
      add_index :account_ledgers, :status
    end
  end
end
