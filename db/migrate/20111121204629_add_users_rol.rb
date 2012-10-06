class AddUsersRol < ActiveRecord::Migration
  def up
    change_table "common.users" do |t|
      t.string  :rol
      t.boolean :active, :default => true
    end
  end

  def down
    change_table "common.users" do |t|
      t.remove :rol
      t.remove :active
    end
  end
end
