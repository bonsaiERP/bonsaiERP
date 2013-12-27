class AddAccountsHstoreExtras < ActiveRecord::Migration
  def up
    PgTools.all_schemas do |schema|
      next  if schema == 'common'
      PgTools.change_schema schema
      execute "ALTER TABLE accounts ADD COLUMN extras public.hstore"
    end
  end

  def down
    PgTools.all_schemas do |schema|
      next  if schema == 'common'
      PgTools.change_schema schema
      execute "ALTER TABLE accounts DROP COLUMN extras"
    end
  end
end
