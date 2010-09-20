class CreateStores < ActiveRecord::Migration
  def self.up
    create_table :stores do |t|
      t.string :name
      t.string :address
      t.string :phone
      t.boolean :active
      t.string :description

      t.integer :organisation_id

      t.timestamps
    end

    add_index(:stores, :organisation_id)
  end

  def self.down
    drop_table :stores
  end
end
