class AddUsersAddress < ActiveRecord::Migration
  def self.up
    add_column :users, :address, :string
  end

  def self.down
    remove_column :users, :address
  end
end
