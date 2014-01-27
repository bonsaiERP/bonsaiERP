class CreateInventoryOperationDetails < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      create_table :inventory_operation_details do |t|
        t.integer :inventory_operation_id
        t.integer :item_id
        t.integer :store_id

        t.decimal :quantity, :precision => 14, :scale => 2, default: 0.0

        t.timestamps
      end

      add_index :inventory_operation_details, :inventory_operation_id
      add_index :inventory_operation_details, :item_id
      add_index :inventory_operation_details, :store_id
    end
  end
end
