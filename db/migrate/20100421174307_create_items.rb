class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items, :id => false do |t|
      t.string :id, :limit => 36, :null => false
      t.string :unit_id, :limit => 36
      t.string :itemable_id, :limit => 36
      t.string :itemable_type
      t.string :name
      t.string :description
      t.string :type
      t.boolean :integer, :default => false
      t.boolean :product, :default => false
      t.boolean :stockable, :default => false
      t.boolean :visible, :default => true

      t.string :organisation_id, :limit => 36

      t.timestamps
    end
    add_index :items, :id
    add_index :items, :organisation_id
    add_index :items, :unit_id
    add_index :items, :itemable_id
    add_index :items, :itemable_type
  end

  def self.down
    drop_table :items
  end
end
