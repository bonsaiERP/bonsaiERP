class AddPaymentsReference < ActiveRecord::Migration
  def self.up
    add_column :payments, :reference, :string, :limit => 50
    add_index :payments, :reference
  end

  def self.down
    remove_column :payments, :reference
  end
end
