class ConvertOrgSettingsToJson < ActiveRecord::Migration
  def up
    execute("ALTER TABLE common.organisations ALTER COLUMN settings TYPE JSONB USING CAST(settings as JSONB);")
  end

  def down
  end
end
