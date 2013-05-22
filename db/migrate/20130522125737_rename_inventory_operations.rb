class RenameInventoryOperations < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      remove_index :inventory_operation_details, :inventory_operation_id

      rename_table :inventory_operations, :inventories
      rename_table :inventory_operation_details, :inventory_details

      rename_column :inventory_details, :inventory_operation_id, :inventory_id
      add_index :inventory_details, :inventory_id
    end
  end

  def down
    PgTools.with_schemas except: 'common' do
      rename_table :inventories, :inventory_operations
      rename_table :inventory_details, :inventory_operation_details
    end
  end
end
