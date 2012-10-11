class AddUsersActive < ActiveRecord::Migration
  def up
    change_table "common.users" do |t|
      t.boolean :active, :default => true
    end
  end

  def down
    change_table "common.users" do |t|
      t.remove :active
    end
  end
end
