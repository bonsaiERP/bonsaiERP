class AddContactsStaff < ActiveRecord::Migration
  def self.up
    add_column :contacts, :position, :string
    add_column :contacts, :active, :boolean, :default => true

    add_index :contacts, :active
  end

  def self.down
    remove_column :contacts, :position
  end
end
