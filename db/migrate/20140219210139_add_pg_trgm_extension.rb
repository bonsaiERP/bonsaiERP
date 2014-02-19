class AddPgTrgmExtension < ActiveRecord::Migration
  def up
    execute 'CREATE EXTENSION pg_trgm SCHEMA public'
  end

  def down
    execute 'DROP EXTENSION pg_trgm'
  end
end
