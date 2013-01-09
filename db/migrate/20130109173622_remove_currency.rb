class RemoveCurrency < ActiveRecord::Migration
  def up
    # Very important migration that will eliminate currency_id from all
    # tables
    remove_column :account_ledgers, :currency_id
    remove_column :accounts, :currency_id
    remove_column :money_stores, :currency_id
    remove_column :transaction_details, :currency_id
    remove_column :transactions, :currency_id
  end

  def down
  end
end
