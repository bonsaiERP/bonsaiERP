class AddUsers < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.string :abbreviation, :limit => 10
    end
  end

  def down
  end
end
