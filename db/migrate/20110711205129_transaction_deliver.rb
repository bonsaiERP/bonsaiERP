class TransactionDeliver < ActiveRecord::Migration
  def up
    change_table :transactions do |t|
      t.boolean :deliver, :default => false
      t.datetime :deliver_datetime
      t.integer :deliver_approver_id
      t.string :deliver_reason
    end
    add_index :transactions, :deliver
    add_index :transactions, :deliver_approver_id
  end

  def down
    remove_column :transactions, :deliver
    remove_column :transactions, :deliver_approver_id
    remove_column :transactions, :deliver_reason
  end
end
