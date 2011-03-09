class AddPaymentsState < ActiveRecord::Migration
  def self.up
    add_column :payments, :state, :string, :limit => 20
    add_index :payments, :state
  end

  def self.down
    remove_column :payments, :state
  end
end
