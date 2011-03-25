class AddTransactionDetailsOriginalPrice < ActiveRecord::Migration
  def self.up
    add_column :transaction_details, :original_price, :decimal, :precision => 14, :scale => 2
  end

  def self.down
    remove_column :transaction_details, :original_price
  end
end
