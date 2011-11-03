class AddTransactionsModifiedBy < ActiveRecord::Migration
  def up
    change_table :transactions do |t|
      t.integer :modified_by
    end
    add_index :transactions, :modified_by
  end

  def down
    remove_column :transactions, :modified_by
  end
end
