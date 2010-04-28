class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts, :id => false do |t|
      t.string :id, :limit => 36, :null => false
      t.string :name, :limit => 100
      t.string :address, :limit => 250
      t.string :address_alt, :limit => 250
      t.string :phone, :limit => 20
      t.string :mobile, :limit => 20
      t.string :type
      t.string :email, :limit => 200
      t.string :tax_number, :limit => 30
      t.string :aditional_info, :limit => 250

      t.string :organisation_id, :limit => 36, :null => false

      t.timestamps
    end

    add_index(:contacts, :id)
    add_index(:contacts, :organisation_id)
  end

  def self.down
    drop_table :contacts
  end
end
