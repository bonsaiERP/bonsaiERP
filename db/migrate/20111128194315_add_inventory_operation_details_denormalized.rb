class AddInventoryOperationDetailsDenormalized < ActiveRecord::Migration
  def up
    change_table :inventory_operation_details do |t|
      t.integer :store_id
      t.integer :contact_id
      t.integer :transaction_id
      t.string :operation, :limit => 10
    end
    add_index :inventory_operation_details, :store_id
    add_index :inventory_operation_details, :contact_id
    add_index :inventory_operation_details, :transaction_id
    add_index :inventory_operation_details, :operation
  end

  def down
    remove_column :inventory_operation_details, :store_id
    remove_column :inventory_operation_details, :contact_id
    remove_column :inventory_operation_details, :transaction_id
    remove_column :inventory_operation_details, :operation
  end
end
