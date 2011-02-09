class AddTransactionsPaymentDate < ActiveRecord::Migration
  def self.up
    add_column :transactions, :payment_date, :date
    add_index :transactions, :payment_date
  end

  def self.down
    remove_column :transactions, :payment_date, :date
  end
end
