class AddTransactionDiscountInvoice < ActiveRecord::Migration
  def self.up
    add_column :transactions, :discount, :decimal, :precision => 5, :scale => 2
  end

  def self.down
    remove_column :transactions, :discount
  end
end
