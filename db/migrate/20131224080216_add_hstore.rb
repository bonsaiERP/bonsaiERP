class AddHstore < ActiveRecord::Migration
  def up
    PgTools.with_schemas only: 'public' do
      execute 'CREATE EXTENSION hstore'
    end
  end

  def down
    PgTools.with_schemas only: 'public' do
      execute 'DROP EXTENSION hstore'
    end
  end
end
