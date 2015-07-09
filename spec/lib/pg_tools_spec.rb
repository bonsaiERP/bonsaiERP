require 'spec_helper'

describe PgTools do
  def execute(sql)
    ActiveRecord::Base.connection.execute(sql)
  end

  def create_schema(schema)
    execute("CREATE SCHEMA #{schema}")
  end

  context '::with_schemas' do
    it ':except' do
      create_schema "bonsai"
      create_schema "club_vegetariano"

      arr = []
      expect(PgTools.all_schemas.sort).to eq(["bonsai", "club_vegetariano", "common", "public"])

      PgTools.with_schemas except: 'common' do
        arr << ActiveRecord::Base.connection.current_schema
      end

      expect(arr.sort).to eq(["bonsai", "club_vegetariano", "public"])
    end

    it ':only' do
      expect(PgTools.all_schemas.sort).to eq(["common", "public"])
      arr = []

      PgTools.with_schemas only: 'common' do
        arr << ActiveRecord::Base.connection.current_schema
      end

      expect(arr).to eq(["common"])
    end
  end
end
