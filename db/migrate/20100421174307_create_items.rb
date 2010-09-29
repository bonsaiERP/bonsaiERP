class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :unit_id
      t.string :name
      t.string :description
      t.string :code, :limit => 100
      t.boolean :integer, :default => false # denormalized data
      t.boolean :product, :default => false
      t.boolean :stockable, :default => false
      t.boolean :active, :default => true
      t.decimal :price, :precision => 14, :scale => 2
      t.decimal :discount, :precision => 5, :scale => 2, :default => 0
      t.string :quantities

      t.boolean :visible, :default => true

      t.integer :organisation_id, :null => false

      t.timestamps
    end

    add_index :items, :organisation_id
    add_index :items, :unit_id
    add_index :items, :code
  end

  def self.down
    drop_table :items
  end
end
