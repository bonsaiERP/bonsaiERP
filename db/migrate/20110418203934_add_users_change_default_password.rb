class AddUsersChangeDefaultPassword < ActiveRecord::Migration
  def self.up
    add_column :users, :change_default_password, :boolean, :default => false
  end

  def self.down
    remove_column :users, :change_default_password
  end
end
