class AddAccountLedgersContactId < ActiveRecord::Migration
  def self.up
    add_column :account_ledgers, :contact_id, :integer
    add_index :account_ledgers, :contact_id
  end

  def self.down
    remove_column :account_ledgers, :contact_id
  end
end
