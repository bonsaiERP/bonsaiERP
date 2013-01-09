class AddCurrencyToOrganisations < ActiveRecord::Migration
  def change
    change_table 'common.organisations' do |t|
      t.string :currency, limit: 10
    end

    add_index 'common.organisations', :currency
  end
end
