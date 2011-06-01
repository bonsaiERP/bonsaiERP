class CreateBanks < ActiveRecord::Migration
  def change
    create_table :banks do |t|
      t.references :organisation
      t.references :currency
      t.string :type, :limit => 30
      t.string :name
      t.string :name, :limit => 100
      t.string :number, :limit => 30
      t.string :address
      t.string :website
      t.string :phone

      t.timestamps
    end
    add_index :banks, :organisation_id
    add_index :banks, :currency_id
    add_index :banks, :type
    add_index :banks, :name
  end
end
