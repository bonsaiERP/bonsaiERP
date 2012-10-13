class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.integer :item_id
      t.decimal :unitary_cost, :precision => 14, :scale => 2
      t.decimal :price, :precision => 14, :scale => 2
      t.string :discount

      t.timestamps
    end
    add_index :prices, :item_id
  end

  # Creates a price using the item as base
  def self.create_with_item(item)
    if item.product?
      Price
    else
    end
  end
end
