class AddTransactionsContactId < ActiveRecord::Migration
  def up
    change_table :transactions do |t|
      t.integer :contact_id
    end
    add_index :transactions, :contact_id
  end

  def down
  end
end
