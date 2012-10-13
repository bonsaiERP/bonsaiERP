class ChangeInventoryOperationsContact < ActiveRecord::Migration
  def up
    change_table :inventory_operations do |t|
      t.remove  :contact_id
      t.integer :account_id
    end
    add_index :inventory_operations, :account_id
  end

  def down
    change_table :inventory_operations do |t|
      t.integer :contact_id
      t.remove  :account_id
    end
    add_index :inventory_operations, :contact_id
  end
end
