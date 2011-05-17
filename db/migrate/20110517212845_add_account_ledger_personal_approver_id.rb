class AddAccountLedgerPersonalApproverId < ActiveRecord::Migration
  def self.up
    add_column :account_ledgers, :personal_approver_id, :integer
    add_index :account_ledgers, :personal_approver_id
  end

  def self.down
    remove_column :account_ledgers, :personal_approver_id
  end
end
