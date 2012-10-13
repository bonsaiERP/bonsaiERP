class CreateInventoryOperationDetails < ActiveRecord::Migration
  def change
    create_table :inventory_operation_details do |t|
      t.integer :inventory_operation_id
      t.integer :item_id

      t.decimal :quantity, :precision => 14, :scale => 2
      t.decimal :unitary_cost, :precision => 14, :scale => 2

      t.timestamps
    end

    add_index :inventory_operation_details, :inventory_operation_id
    add_index :inventory_operation_details, :item_id

  end
end
