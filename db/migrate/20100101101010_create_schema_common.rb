class CreateSchemaCommon < ActiveRecord::Migration
  def up
    PgTools.create_schema 'common'
  end

  def down
    PgTools.drop_schema 'common'
  end
end
