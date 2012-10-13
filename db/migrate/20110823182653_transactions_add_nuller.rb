class TransactionsAddNuller < ActiveRecord::Migration
  def up
    change_table :transactions do |t|
      t.integer  :nuller_id
      t.datetime :nuller_datetime
    end
    add_index :transactions, :nuller_id
  end

  def down
    change_table :transactions do |t|
      t.remove :nuller_id
      t.remove :nuller_datetime
    end
  end
end
