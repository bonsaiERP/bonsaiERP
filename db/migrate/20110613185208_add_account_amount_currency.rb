class AddAccountAmountCurrency < ActiveRecord::Migration
  def up
    change_table :accounts do |t|
      t.string :amount_currency, :limit => 500
    end
  end

  def down
    remove_column :accounts, :amount_currency
  end
end
