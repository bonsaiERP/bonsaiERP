class CreateAccountLedgers < ActiveRecord::Migration
  def self.up
    create_table :account_ledgers do |t|
      t.integer :organisation_id
      t.integer :account_id
      t.integer :currency_id
      t.decimal :amount, :precision => 14, :scale => 2
      t.date :date
      t.integer :payment_id
      t.boolean :income

      t.timestamps
    end

    add_index :account_ledgers, :organisation_id
    add_index :account_ledgers, :account_id
    add_index :account_ledgers, :currency_id
    add_index :account_ledgers, :date
    add_index :account_ledgers, :payment_id
    add_index :account_ledgers, :income
  end

  def self.down
    drop_table :account_ledgers
  end
end
