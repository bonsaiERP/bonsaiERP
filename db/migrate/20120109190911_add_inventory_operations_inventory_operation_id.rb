class AddInventoryOperationsInventoryOperationId < ActiveRecord::Migration
  def up
    change_table :inventory_operations do |t|
      t.integer :transference_id
      t.integer :store_to_id
    end

    add_index :inventory_operations, :transference_id
  end

  def down
    remove_column :inventory_operations, :transference_id
  end
end
