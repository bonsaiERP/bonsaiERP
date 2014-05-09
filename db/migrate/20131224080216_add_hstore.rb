class AddHstore < ActiveRecord::Migration
  def up
    execute "CREATE EXTENSION IF NOT EXISTS hstore SCHEMA public"
  end

  def down
    execute 'DROP EXTENSION IF EXISTS hstore'
  end
end
