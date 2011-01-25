class AddTransactionGrossTotalCash < ActiveRecord::Migration
  def self.up
    add_column :transactions, :gross_total, :decimal, :precision => 14, :scale => 2
    add_column :transactions, :cash, :boolean, :default => true
    add_index :transactions, :cash
  end

  def self.down
    remove_column :transactions, :gross_total
    remove_column :transactions, :cash
  end
end
