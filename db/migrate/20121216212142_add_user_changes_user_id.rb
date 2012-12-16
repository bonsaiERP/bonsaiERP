class AddUserChangesUserId < ActiveRecord::Migration
  def up
    change_table :user_changes do |t|
      t.integer :user_id
    end

    add_index :user_changes, :user_id
  end

  def down
    remove_column :user_changes, :user_id
  end
end
