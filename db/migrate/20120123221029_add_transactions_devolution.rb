class AddTransactionsDevolution < ActiveRecord::Migration
  def up
    change_table :transactions do |t|
      t.boolean :devolution, :default => false
    end

    add_index :transactions, :devolution
  end

  def down
    remove_column :transactions, :devolution
  end
end
