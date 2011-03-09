class CurrencyRatesRemoveOrganisationId < ActiveRecord::Migration
  def self.up
    remove_column :currency_rates, :organisation_id
  end
end
