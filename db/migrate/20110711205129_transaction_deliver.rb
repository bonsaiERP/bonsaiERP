class TransactionDeliver < ActiveRecord::Migration
  def up
    change_table :transactions do |t|
      t.boolean  :deliver, :default => false
      t.datetime :deliver_datetime
      t.integer  :deliver_approver_id
      t.string   :deliver_reason
    end
    add_index :transactions, :deliver
    add_index :transactions, :deliver_approver_id
  end

  def down
    change_table :transactions do |t|
      t.remove :deliver
      t.remove :deliver_datetime
      t.remove :deliver_approver_id
      t.remove :deliver_reason
    end
  end
end
