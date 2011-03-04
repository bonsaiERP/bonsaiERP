class AddAccountLedgersReference < ActiveRecord::Migration
  def self.up
    add_column :account_ledgers, :reference, :string, :limit => 100
    add_index :account_ledgers, :reference
  end

  def self.down
    remove_column :account_ledgers, :reference, :string
  end
end
