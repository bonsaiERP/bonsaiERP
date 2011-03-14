class AddPaymentsExchangeRate < ActiveRecord::Migration
  def self.up
    add_column :payments, :exchange_rate, :decimal, :precision => 14, :scale => 2
  end

  def self.down
    remove_column :payments, :exchange_rate
  end
end
