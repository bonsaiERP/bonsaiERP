class CreateSchemaCommon < ActiveRecord::Migration
  def up
    PgTools.create_schema 'common' unless PgTools.schema_exists?('common')
  end

  def down
    PgTools.drop_schema 'common'
  end
end
