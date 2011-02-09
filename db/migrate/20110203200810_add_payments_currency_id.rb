class AddPaymentsCurrencyId < ActiveRecord::Migration
  def self.up
    add_column :payments, :currency_id, :integer
    add_index :payments, :currency_id
  end

  def self.down
    remove_column :payments, :currency_id
  end
end
