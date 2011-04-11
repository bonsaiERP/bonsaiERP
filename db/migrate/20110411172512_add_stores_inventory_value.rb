class AddStoresInventoryValue < ActiveRecord::Migration
  def self.up
    add_column :stores, :inventory_value, :decimal, :precision => 14, :scale => 2
    add_index :stores, :inventory_value
  end

  def self.down
    remove_column :stores, :inventory_value
  end
end
