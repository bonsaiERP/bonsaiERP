class AddTransactionDetailsBalance < ActiveRecord::Migration
  def self.up
    add_column :transaction_details, :balance, :decimal, :precision => 14, :scale => 2
  end

  def self.down
    remove_column :transaction_details, :balance
  end
end
