class CreateCurrenciesOrganisations < ActiveRecord::Migration
  def self.up
    create_table :currencies_organisations, :id => false do |t|
      t.integer :currency_id
      t.integer :organisation_id
    end

    add_index :currencies_organisations, [:currency_id, :organisation_id], :name => 'currencies_orgs_c_id_org_id'
  end

  def self.down
    drop_table :currencies_organisations
  end
end
