class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :matchcode
      t.string :first_name, :limit => 100
      t.string :organisation_name, :limit => 100
      t.string :address, :limit => 250
      t.string :address_alt, :limit => 250
      t.string :phone, :limit => 20
      t.string :mobile, :limit => 20
      t.string :email, :limit => 200
      t.string :tax_number, :limit => 30
      t.string :aditional_info, :limit => 250

      t.string  :code
      t.string  :type
      t.string  :last_name,  :limit => 100
      t.string  :position
      t.boolean :active,     :default => true

      t.timestamps
    end

    add_index :contacts, :matchcode
    add_index :contacts, :first_name
    add_index :contacts, :last_name
    add_index :contacts, :type
  end
end
