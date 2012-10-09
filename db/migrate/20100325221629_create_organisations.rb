class CreateOrganisations < ActiveRecord::Migration
  def change
    create_table "common.organisations" do |t|
      t.integer :country_id
      t.integer :currency_id
      t.string  :name, :limit => 100
      t.string  :address
      t.string  :address_alt
      t.string  :phone     , :limit => 20
      t.string  :phone_alt , :limit => 20
      t.string  :mobile    , :limit => 20
      t.string  :email
      t.string  :website
      t.integer :user_id

      t.date    :due_date
      t.text    :preferences
      t.boolean :base_accounts, :default => false

      t.string :tenant

      t.timestamps
    end

    add_index "common.organisations", :country_id
    add_index "common.organisations", :currency_id
    add_index "common.organisations", :due_date
    add_index "common.organisations", :tenant, unique: true
  end
end
