class AddTransactionsDelivered < ActiveRecord::Migration
  def up
    change_table :transactions do |t|
      t.boolean :delivered, :default => false
    end
    add_index :transactions, :delivered
  end

  def down
    remove_column :transactions, :delivered
  end
end
