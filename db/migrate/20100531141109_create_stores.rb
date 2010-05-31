class CreateStores < ActiveRecord::Migration
  def self.up
    create_table :stores, :id => false do |t|
      t.string :id, :limit => 36, :null => false
      t.string :name
      t.string :address
      t.string :phone
      t.boolean :active
      t.string :description

      t.string :organisation_id, :limit => 36, :null => false

      t.timestamps
    end

    add_index(:stores, :id)
    add_index(:stores, :organisation_id)
  end

  def self.down
    drop_table :stores
  end
end
