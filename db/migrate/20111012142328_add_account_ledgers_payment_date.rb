class AddAccountLedgersPaymentDate < ActiveRecord::Migration
  def up
    change_table :account_ledgers do |t|
      t.date :payment_date
    end
  end

  def down
    remove_column :account_ledgers, :payment_date
  end
end
