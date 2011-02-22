class DropCurrenciesOrganisations < ActiveRecord::Migration
  def self.up
    drop_table :currencies_organisations
  end
end
