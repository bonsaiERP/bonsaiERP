class CreateOrganisations < ActiveRecord::Migration
  def self.up
    create_table :organisations, :id => false do |t|
      t.string :id, :limit => 36, :null => false
      t.string :country_id, :limit => 36
      t.string :currency_id, :limit => 36
      t.string :name, :limit => 100
      t.string :address
      t.string :address_alt
      t.string :phone, :limit => 20
      t.string :phone_alt, :limit => 20
      t.string :mobile, :limit => 20
      t.string :email
      t.string :website
      t.string :user_id, :limit => 36

      t.timestamps
    end
    add_index :organisations, :id
    add_index :organisations, :country_id
    add_index :organisations, :currency_id
  end

  def self.down
    drop_table :organisations
  end
end
