class AddPaymentsAccountId < ActiveRecord::Migration
  def self.up
    add_column :payments, :account_id, :integer
    add_index :payments, :account_id
  end

  def self.down
    remove_column :payments, :account_id
  end
end
