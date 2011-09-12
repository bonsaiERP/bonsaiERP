class AddUsersSalt < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.string :salt
    end
  end

  def down
    remove_column :salt
  end
end
