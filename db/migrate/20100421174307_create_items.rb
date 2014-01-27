class CreateItems < ActiveRecord::Migration
  def up
    PgTools.with_schemas except: 'common' do
      create_table :items do |t|
        t.integer :unit_id

        t.decimal :price, precision: 14, scale: 2, default: 0.0
        t.string  :name
        t.string  :description
        t.string  :code, :limit => 100
        t.boolean :for_sale, :default => true
        t.boolean :stockable, :default => true
        t.boolean :active, :default => true

        t.timestamps
      end

      add_index :items, :unit_id
      add_index :items, :code
      add_index :items, :for_sale
      add_index :items, :stockable
    end
  end
end
