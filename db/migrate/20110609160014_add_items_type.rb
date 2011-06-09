class AddItemsType < ActiveRecord::Migration
  def up
    change_table :items do |t|
      t.string :type
      t.string :un_name
      t.string :un_symbol, :limit => 10
    end
    add_index :items, :type
  end

  def down
  end
end
