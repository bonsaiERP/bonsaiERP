class AddAccountLedgersBalances < ActiveRecord::Migration
  def up
    change_table :account_ledgers do |t|
      t.decimal :account_balance, :precision => 14, :scale => 2
      t.decimal :to_balance, :precision => 14, :scale => 2
    end
  end

  def down
  end
end
