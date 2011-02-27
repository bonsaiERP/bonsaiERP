class AddAccountLedgersTransactionId < ActiveRecord::Migration
  def self.up
    add_column :account_ledgers, :transaction_id, :integer
    add_index :account_ledgers, :transaction_id
  end

  def self.down
    remove_column :account_ledgers, :transaction_id
  end
end
