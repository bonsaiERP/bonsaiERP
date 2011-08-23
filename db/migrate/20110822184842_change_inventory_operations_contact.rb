class ChangeInventoryOperationsContact < ActiveRecord::Migration
  def up
    change_table :inventory_operations do |t|
      t.remove  :contact_id
      t.integer :account_id
    end
    add_index :inventory_operations, :account_id
  end

  def down
  end
end
