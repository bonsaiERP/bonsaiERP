class AddContactsCodeType < ActiveRecord::Migration
  def self.up
    add_column :contacts, :code, :string
    add_column :contacts, :type, :string

    add_index :contacts, :code
    add_index :contacts, :type
  end

  def self.down
    remove_column :contacts, :code
    remove_column :contacts, :type
  end
end
