class CreateInventoryOperations < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do

      create_table :inventory_operations do |t|
        t.integer :contact_id
        t.integer :store_id
        t.integer :account_id

        t.date   :date
        t.string :ref_number
        t.string :operation, :limit => 10
        t.string :state

        t.string :description

        t.decimal :total, :precision => 14, :scale => 2, default: 0

        t.integer  :creator_id
        t.integer  :transference_id
        t.integer  :store_to_id
        t.integer  :project_id

        t.boolean :has_error, default: false
        t.string  :error_messages

        t.timestamps
      end

      add_index :inventory_operations, :contact_id
      add_index :inventory_operations, :store_id
      add_index :inventory_operations, :account_id
      add_index :inventory_operations, :project_id

      add_index :inventory_operations, :date
      add_index :inventory_operations, :ref_number
      add_index :inventory_operations, :operation
      add_index :inventory_operations, :state
      add_index :inventory_operations, :has_error
    end
  end
end
