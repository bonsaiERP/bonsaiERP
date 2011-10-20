class AddAccountLedgersCode < ActiveRecord::Migration
  def up
    change_table :account_ledgers do |t|
      t.integer :code
    end
    add_index :account_ledgers, :code
  end

  def down
  end
end
