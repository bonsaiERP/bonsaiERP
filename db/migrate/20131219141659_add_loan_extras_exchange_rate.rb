class AddLoanExtrasExchangeRate < ActiveRecord::Migration
  def change
    change_table :loan_extras do |t|
      t.decimal :exchange_rate, precision: 14, scale: 4, default: 1
    end
  end
end
