class AddAccountLedgersConcilationDescription < ActiveRecord::Migration
  def self.up
    add_column :account_ledgers, :conciliation, :boolean
    add_column :account_ledgers, :description, :text

    add_index :account_ledgers, :conciliation
    add_index :account_ledgers, :description
  end

  def self.down
    remove_column :account_ledgers, :conciliation
    remove_column :account_ledgers, :description
  end
end
