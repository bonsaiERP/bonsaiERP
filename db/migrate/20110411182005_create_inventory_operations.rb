class CreateInventoryOperations < ActiveRecord::Migration
  def self.up
    create_table :inventory_operations do |t|
      t.integer :contact_id
      t.integer :store_id
      t.integer :organisation_id
      t.integer :transaction_id

      t.date :date
      t.string :ref_number
      t.string :operation
      t.string :state
      
      t.string :description

      t.decimal :total, :precision => 14, :scale => 2

      t.timestamps
    end

    add_index :inventory_operations, :contact_id
    add_index :inventory_operations, :organisation_id
    add_index :inventory_operations, :store_id
    add_index :inventory_operations, :transaction_id

    add_index :inventory_operations, :operation
    add_index :inventory_operations, :state
    add_index :inventory_operations, :date
    add_index :inventory_operations, :ref_number
  end

  def self.down
    drop_table :inventory_operations
  end
end
