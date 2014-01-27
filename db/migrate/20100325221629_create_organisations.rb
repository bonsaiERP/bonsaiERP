class CreateOrganisations < ActiveRecord::Migration
  def up
    PgTools.with_schemas only: ['common', 'public'] do
      create_table :organisations do |t|
        t.integer :country_id
        t.string  :name, limit: 100
        t.string  :address
        t.string  :address_alt
        t.string  :phone     , limit: 20
        t.string  :phone_alt , limit: 20
        t.string  :mobile    , limit: 20
        t.string  :email
        t.string  :website
        t.integer :user_id

        t.date    :due_date
        t.text    :preferences
        t.string  :time_zone, limit: 100

        t.string :tenant, limit: 50
        t.string :currency, limit: 10

        t.timestamps
      end

      add_index :organisations, :country_id
      add_index :organisations, :due_date
      add_index :organisations, :tenant, unique: true
      add_index :organisations, :currency
    end
  end
end
