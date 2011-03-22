class AddContactsLastName < ActiveRecord::Migration
  def self.up
    add_column :contacts, :last_name, :string, :limit => 100
    add_index :contacts, :last_name
  end

  def self.down
    remove_column :contacts, :last_name
  end
end
