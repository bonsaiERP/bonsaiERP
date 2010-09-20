class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :unit_id
      t.integer :itemable_id
      t.string :itemable_type
      t.string :name
      t.string :description
      t.string :type
      t.boolean :integer, :default => false
      t.boolean :product, :default => false
      t.boolean :stockable, :default => false
      t.boolean :visible, :default => true

      t.integer :organisation_id

      t.timestamps
    end
    add_index :items, :organisation_id
    add_index :items, :unit_id
    add_index :items, :itemable_id
    add_index :items, :itemable_type
  end

  def self.down
    drop_table :items
  end
end
