class AddAccountsHstoreExtras < ActiveRecord::Migration
  def up
    PgTools.change_schema 'public'
    PgTools.all_schemas.each do |schema|
      next  if schema == 'common'
      execute "ALTER TABLE #{schema}.accounts ADD COLUMN extras public.hstore"
    end
  end

  def down
    PgTools.all_schemas.each do |schema|
      next  if schema == 'common'
      PgTools.change_schema schema
      execute "ALTER TABLE accounts DROP COLUMN IF EXISTS extras"
    end
  end
end
