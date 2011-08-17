class AddAccountLedgersIndexes < ActiveRecord::Migration
  def up
    add_index :account_ledgers, :created_at
  end

  def down
    remove_index :account_ledgers, :created_at
  end
end
