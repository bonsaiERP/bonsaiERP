class CreateUnits < ActiveRecord::Migration
  def self.up
    create_table :units do |t|
      t.string :name, :limit => 100
      t.string :symbol, :limit => 20
      t.boolean :integer, :default => false
      t.boolean :visible, :default => true

      t.integer :organisation_id, :null => false

      t.timestamps
    end

    add_index(:units, :organisation_id)
  end

  def self.down
    drop_table :units
  end
end
