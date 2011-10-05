class AddTransactionsOriginalTotal < ActiveRecord::Migration
  def up
    change_table :transactions do |t|
      t.decimal :original_total, :precision => 14, :scale => 2
      t.boolean :discounted, :default => false
    end

    add_index :transactions, :discounted
  end

  def down
    remove_column :transactions, :original_total
    remove_column :transactions, :discounted
  end
end
