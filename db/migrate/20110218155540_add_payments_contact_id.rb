class AddPaymentsContactId < ActiveRecord::Migration
  def self.up
    add_column :payments, :contact_id, :integer
    add_index :payments, :contact_id
  end

  def self.down
    remove_column :payments, :contact_id
  end
end
