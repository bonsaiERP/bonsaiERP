class AddAccountLedgersStaffId < ActiveRecord::Migration
  def up
    change_table :account_ledgers do |t|
      t.integer :staff_id
    end
    add_index :account_ledgers, :staff_id
  end

  def down
  end
end
