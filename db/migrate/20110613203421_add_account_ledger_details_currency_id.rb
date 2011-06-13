class AddAccountLedgerDetailsCurrencyId < ActiveRecord::Migration
  def up
    change_table :account_ledger_details do |t|
      t.integer :currency_id
    end
    add_index :account_ledger_details, :currency_id
  end

  def down
    remove_column :account_ledger_details, :currency_id
  end
end
