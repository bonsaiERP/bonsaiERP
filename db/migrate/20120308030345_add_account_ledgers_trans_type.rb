class AddAccountLedgersTransType < ActiveRecord::Migration
  def up
    change_table :account_ledgers do |t|
      t.string :transaction_type, :limit => 30
      t.string :status, :default => "none"
    end
    add_index :account_ledgers, :transaction_type
    add_index :account_ledgers, :status
  end

  def down
    remove_column :account_ledgers, :transaction_type
    remove_column :account_ledgers, :status
  end
end
