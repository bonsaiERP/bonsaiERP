class CreateStocks < ActiveRecord::Migration
  def self.up
    create_table :stocks do |t|
      t.integer :store_id
      t.integer :item_id
      t.string  :state, :limit => 20
      t.decimal :unitary_cost, :precision => 14, :scale => 2
      t.decimal :quantity, :precision => 14, :scale => 2
      t.decimal :minimum, :precision => 14, :scale => 2

      t.timestamps
    end

    add_index :stocks, :store_id
    add_index :stocks, :item_id
    add_index :stocks, :state
    add_index :stocks, :minimum

    #add_index :stocks, :unitary_cost
    #add_index :stocks, :quantity
    #add_index :stocks, :minimun_quantity
  end

  def self.down
    drop_table :stocks
  end
end
