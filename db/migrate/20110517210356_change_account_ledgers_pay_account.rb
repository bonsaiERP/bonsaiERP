class ChangeAccountLedgersPayAccount < ActiveRecord::Migration
  def self.up
    remove_column :account_ledgers, :pay_account
    add_column :account_ledgers, :personal, :string, :limit => 15
    add_index :account_ledgers, :personal
  end

  def self.down
  end
end
