class AddPaymentsActive < ActiveRecord::Migration
  def self.up
    add_column :payments, :active, :boolean
    add_index :payments, :active
  end

  def self.down
    remove_column :payments, :active
  end
end
