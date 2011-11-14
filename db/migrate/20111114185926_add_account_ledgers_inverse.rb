class AddAccountLedgersInverse < ActiveRecord::Migration
  def up
    remove_column :account_ledgers, :code
    change_table :account_ledgers do |t|
      t.boolean :inverse, :default => false
    end
    add_index :account_ledgers, :inverse
  end

  def down
    remove_column :account_ledgers, :inverse
  end
end
