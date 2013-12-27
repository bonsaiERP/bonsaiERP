class AddAccountsHstoreExtras < ActiveRecord::Migration
  # Alternative
  #def up
  #  PgTools.all_schemas do |schema|
  #    next  if schema == 'common'
  #    PgTools.change_schema schema
  #    execute "ALTER TABLE accounts ADD COLUMN extras public.hstore"
  #  end
  #end

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
      execute "ALTER TABLE accounts DROP COLUMN extras"
    end
  end
end
