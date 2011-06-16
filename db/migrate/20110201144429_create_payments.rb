class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.integer :transaction_id
      t.integer :organisation_id
      t.string  :ctype

      t.date    :date
      t.decimal :amount, :precision => 14, :scale => 2
      t.decimal :interests_penalties, :precision => 14, :scale => 2
      t.string  :description

      t.integer :account_id
      t.integer :account_ledger_id
      t.integer :contact_id
      t.boolean :active, :default => true
      t.string  :state,     :limit => 20
      t.decimal :exchange_rate, :precision => 14, :scale => 4

      t.timestamps
    end

    add_index :payments, :transaction_id
    add_index :payments, :organisation_id
    add_index :payments, :account_id
    add_index :payments, :account_ledger_id
    add_index :payments, :contact_id
    add_index :payments, :ctype
    add_index :payments, :date
  end

  def self.down
    drop_table :payments
  end
end
