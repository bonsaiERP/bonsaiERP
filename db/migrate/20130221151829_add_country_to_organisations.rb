class AddCountryToOrganisations < ActiveRecord::Migration
  def change
    PgTools.with_schemas only: ['common', 'public'] do
      add_column :organisations, :country_code, :string, limit: 5
      add_index :organisations, :country_code
    end
  end
end
