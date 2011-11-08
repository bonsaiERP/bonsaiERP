class CreateMoneyStores < ActiveRecord::Migration
  def change
    create_table :money_stores do |t|
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
    add_index :money_stores, :currency_id
    add_index :money_stores, :type
    add_index :money_stores, :name
  end
end
