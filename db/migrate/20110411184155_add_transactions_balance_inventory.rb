class AddTransactionsBalanceInventory < ActiveRecord::Migration
  def self.up
    add_column :transactions, :balance_inventory, :decimal, :precision => 14, :scale => 2

    add_index :transactions, :balance_inventory
  end

  def self.down
    remove_column :transactions, :balance_inventory
  end
end
