class AddItemsForSale < ActiveRecord::Migration
  def up
    change_table :items do |t|
      t.boolean :for_sale, default: false
    end

    add_index :items, :for_sale
    add_index :items, :stockable
  end

  def down
    remove_index :items, :stockable
    remove_column :items, :for_sale
  end
end
