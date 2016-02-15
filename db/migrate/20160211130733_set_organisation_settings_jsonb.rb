class SetOrganisationSettingsJsonb < ActiveRecord::Migration
  def up
    PgTools.with_schemas only: 'common' do
      change_column :organisations, :settings, :hstore, :default => nil
    end
  end

  def down
    PgTools.with_schemas only: 'common' do
      change_column :organisations, :settings, :hstore, :default => {"inventory"=>"true"}
    end
  end
end
