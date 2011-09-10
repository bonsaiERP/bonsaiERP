class AddInventoryOperationsCreator < ActiveRecord::Migration
  def up
    change_table :inventory_operations do |t|
      t.integer :creator_id
    end
    add_index :inventory_operations, :creator_id
  end

  def down
    remove_column :inventory_operations, :creator_id
  end
end
