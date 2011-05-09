class AddPaymentsDeletedAccountLedger < ActiveRecord::Migration
  def self.up
    add_column :payments, :deleted_account_ledger_id, :integer
    add_index :payments, :deleted_account_ledger_id
  end

  def self.down
    remove_column :payments, :deleted_account_ledger_id
  end
end
