class AddAccountLedgersUsersAccountLedgerId < ActiveRecord::Migration
  def self.up
    add_column :account_ledgers, :creator_id, :integer
    add_column :account_ledgers, :approver_id, :integer
    add_column :account_ledgers, :account_ledger_id, :integer
  end

  def self.down
    remove_column :account_ledgers, :creator_id
    remove_column :account_ledgers, :approver_id
    remove_column :account_ledgers, :account_ledger_id
  end
end
