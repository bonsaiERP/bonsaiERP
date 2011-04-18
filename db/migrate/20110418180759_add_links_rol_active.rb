class AddLinksRolActive < ActiveRecord::Migration
  def self.up
    add_column :links, :rol, :string, :limit => 50
    add_column :links, :active, :boolean, :default => true
  end

  def self.down
    remove_column :links, :rol
    remove_column :links, :active
  end
end
