class AddStockUserId < ActiveRecord::Migration
  def up
    change_table :stocks do |t|
      t.integer :user_id
    end
    add_index :stocks, :user_id
    add_index :stocks, :quantity
    add_index :stocks, :updated_at
  end

  def down
    remove_column :stocks, :user_id
    remove_index :stocks, :quantity
    remove_index :stocks, :updated_at
  end
end
