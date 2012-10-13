class AddAccountLedgersBalances < ActiveRecord::Migration
  def up
    change_table :account_ledgers do |t|
      t.decimal :account_balance, :precision => 14, :scale => 2
      t.decimal :to_balance, :precision => 14, :scale => 2
    end
  end

  def down
    change_table :account_ledgers do |t|
      t.remove :account_balance
      t.remove :to_balance
    end
  end
end
