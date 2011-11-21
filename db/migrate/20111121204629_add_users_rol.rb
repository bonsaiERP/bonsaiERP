class AddUsersRol < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.string :rol
      t.boolean :active, :default => true
    end
  end

  def down
    remove_column :users, :rol
    remove_column :users, :active
  end
end
