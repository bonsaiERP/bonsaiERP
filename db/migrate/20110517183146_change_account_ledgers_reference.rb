class ChangeAccountLedgersReference < ActiveRecord::Migration
  def self.up
    change_column :account_ledgers, :reference, :string, :limit => 255
  end

  def self.down
  end
end
