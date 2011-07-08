class CreateAccountLedgers < ActiveRecord::Migration
  def self.up
    create_table :account_ledgers do |t|
      t.integer :organisation_id
      t.string  :reference
      t.integer :currency_id
      t.integer :account_id
      t.integer :to_id
      t.date    :date
      t.string  :operation, :limit => 20

      t.boolean :conciliation, :default => true
      t.decimal :amount, :precision => 14, :scale => 2
      t.decimal :exchange_rate, :precision => 14, :scale => 4

      t.decimal :interests_penalties, :precision => 14, :scale => 2, :default => 0

      t.string  :description

      t.integer :transaction_id
      t.integer :creator_id
      t.integer :approver_id
      t.integer :nuller_id
      t.boolean :active, :default => true

      t.timestamps
    end

    add_index :account_ledgers, :organisation_id
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
  end

  def self.down
    drop_table :account_ledgers
  end
end
