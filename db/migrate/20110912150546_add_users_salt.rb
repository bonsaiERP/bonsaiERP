class AddUsersSalt < ActiveRecord::Migration
  def up
    change_table "common.users" do |t|
      t.string :salt
    end
  end

  def down
    change_table "common.users" do |t|
      t.remove :salt
    end
  end
end
