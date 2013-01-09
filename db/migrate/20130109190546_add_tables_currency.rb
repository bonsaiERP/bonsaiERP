class AddTablesCurrency < ActiveRecord::Migration
  def up
    add_column :account_ledgers, :currency, :string, limit: 10
    add_column :accounts, :currency, :string, limit: 10
    add_column :money_stores, :currency, :string, limit: 10
    add_column :transaction_details, :currency,:string, limit: 10
    add_column :transactions, :currency, :string, limit: 10


    add_index :account_ledgers, :currency
    add_index :accounts, :currency
    add_index :money_stores, :currency
    add_index :transaction_details, :currency
    add_index :transactions, :currency
  end

  def down
  end
end
