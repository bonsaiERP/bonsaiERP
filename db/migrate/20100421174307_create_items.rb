class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :unit_id
      t.string :name
      t.string :description
      t.boolean :integer, :default => false # denormalized data
      t.boolean :product, :default => false
      t.boolean :stockable, :default => false
      t.boolean :visible, :default => true

      t.integer :organisation_id, :null => false

      t.timestamps
    end
    add_index :items, :organisation_id
    add_index :items, :unit_id
  end

  def self.down
    drop_table :items
  end
end
