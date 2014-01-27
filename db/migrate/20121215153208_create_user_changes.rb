class CreateUserChanges < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do

      create_table :user_changes do |t|
        t.string :name
        t.integer :user_id
        t.string :user_changeable_type
        t.integer :user_changeable_id
        t.text :description

        t.timestamps
      end

      add_index :user_changes, :user_id
      add_index :user_changes, :user_changeable_id
      add_index :user_changes, :user_changeable_type
    end
  end
end
