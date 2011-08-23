class TransactionsAddNuller < ActiveRecord::Migration
  def up
    change_table :transactions do |t|
      t.integer  :nuller_id
      t.datetime :nuller_datetime
    end
    add_index :transactions, :nuller_id
  end

  def down
  end
end
