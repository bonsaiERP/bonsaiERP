class AddInventoryOperationsContact < ActiveRecord::Migration
  def up
    change_table :inventory_operations do |t|
      t.remove  :account_id
      t.integer :contact_id
    end
    add_index :inventory_operations, :contact_id
  end

  def down
  end
end
