class AddAccountLedgersNullerId < ActiveRecord::Migration
  def self.up
    add_column :account_ledgers, :nuller_id, :integer
    add_index  :account_ledgers, :nuller_id
  end

  def self.down
    remove_column :account_ledgers, :nuller_id
  end
end
