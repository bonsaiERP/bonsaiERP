class CreateAccountLedgers < ActiveRecord::Migration
  def change
    create_table :account_ledgers do |t|
      t.string   :reference
      t.integer  :currency_id
      t.integer  :account_id
      t.integer  :to_id
      t.datetime :date
      t.string   :operation, :limit => 20

      t.boolean :conciliation, :default => true
      t.decimal :amount, :precision => 14, :scale => 2
      t.decimal :exchange_rate, :precision => 14, :scale => 4

      t.decimal :interests_penalties, :precision => 14, :scale => 2, :default => 0

      t.string  :description

      t.integer :transaction_id
      t.integer :creator_id # related with created_at
      t.integer :approver_id
      t.datetime :approver_datetime # conciliation
      t.integer :nuller_id
      t.datetime :nuller_datetime # null
      t.boolean :active, :default => true

      t.boolean :has_error, default: false
      t.string  :error_messages

      t.timestamps
    end

    add_index :account_ledgers, :currency_id
    add_index :account_ledgers, :account_id
    add_index :account_ledgers, :to_id
    add_index :account_ledgers, :date
    add_index :account_ledgers, :conciliation
    add_index :account_ledgers, :operation
    add_index :account_ledgers, :reference
    add_index :account_ledgers, :transaction_id
    add_index :account_ledgers, :approver_id
    add_index :account_ledgers, :creator_id
    add_index :account_ledgers, :nuller_id
    add_index :account_ledgers, :active
    add_index :account_ledgers, :has_error
  end
end
