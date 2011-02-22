class AddCurrencyRatesDate < ActiveRecord::Migration
  def self.up
    add_column :currency_rates, :date, :date
    add_index :currency_rates, :date
  end

  def self.down
    remove_column :currency_rates, :date
  end
end
