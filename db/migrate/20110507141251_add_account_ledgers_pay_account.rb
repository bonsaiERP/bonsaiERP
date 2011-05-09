class AddAccountLedgersPayAccount < ActiveRecord::Migration
  def self.up
    add_column :account_ledgers, :pay_account, :boolean, :default => false
    add_index :account_ledgers, :pay_account
  end

  def self.down
    remove_column :account_ledgers, :pay_account
  end
end
