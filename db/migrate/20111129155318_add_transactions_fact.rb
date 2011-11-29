class AddTransactionsFact < ActiveRecord::Migration
  def up
    change_table :transactions do |t|
      t.boolean :fact, :default => true
    end
    add_index :transactions, :fact
  end

  def down
    remove_column :transactions, :fact
  end
end
