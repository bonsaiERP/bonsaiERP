class AddAccountLedgerDetailsReference < ActiveRecord::Migration
  def up
    change_table :account_ledger_details do |t|
      t.string :reference
      t.string :operation, :limit => 20
      t.string :state,     :limit => 20
    end
    add_index :account_ledger_details, :reference
    add_index :account_ledger_details, :operation
    add_index :account_ledger_details, :state
  end

  def down
    remove_index :account_ledger_details, :reference 
    remove_index :account_ledger_details, :operation 
    remove_index :account_ledger_details, :state 

    remove_column :account_ledger_details, :reference
    remove_column :account_ledger_details, :operation
    remove_column :account_ledger_details, :state
  end
end
