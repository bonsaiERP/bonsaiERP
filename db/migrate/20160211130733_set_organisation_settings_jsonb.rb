class SetOrganisationSettingsJsonb < ActiveRecord::Migration
  def change
    PgTools.with_schemas only: 'common' do
      rename_column :organisations, :settings, :settings_old
      add_column :organisations, :settings, :jsonb, default: {}
    end
  end
end
