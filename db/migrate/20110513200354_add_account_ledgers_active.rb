class AddAccountLedgersActive < ActiveRecord::Migration
  def self.up
    add_column :account_ledgers, :active, :boolean, :default => true
    add_index :account_ledgers, :active
  end

  def self.down
    remove_column :account_ledgers, :active
  end
end
