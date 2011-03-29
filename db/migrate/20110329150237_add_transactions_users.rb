class AddTransactionsUsers < ActiveRecord::Migration
  def self.up
    add_column :transactions, :creator_id, :integer
    add_column :transactions, :approver_id, :integer
  end

  def self.down
    remove_column :transactions, :creator_id
    remove_column :transactions, :approver_id
  end
end
