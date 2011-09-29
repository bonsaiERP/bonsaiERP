class AddAccountsIndexAmount < ActiveRecord::Migration
  def up
    add_index :accounts, :amount
  end

  def down
  end
end
