class RenameContactsName < ActiveRecord::Migration
  def up
    rename_column :contacts, :name, :first_name
  end

  def down
    rename_column :contacts, :first_name, :name
  end
end
