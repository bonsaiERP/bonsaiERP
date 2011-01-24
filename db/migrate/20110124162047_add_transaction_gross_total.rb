class AddTransactionGrossTotal < ActiveRecord::Migration
  def self.up
    add_column :transactions, :gross_total, :decimal, :precision => 14, :scale => 2
  end

  def self.down
    remove_column :transactions, :gross_total
  end
end
