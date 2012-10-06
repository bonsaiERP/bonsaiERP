class AddUsers < ActiveRecord::Migration
  def up
    change_table "common.users" do |t|
      t.string :abbreviation, :limit => 10
    end
  end

  def down
    change_table "common.users" do |t|
      t.remove :abbreviation
    end
  end
end
