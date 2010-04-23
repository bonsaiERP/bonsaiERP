class CreateUnits < ActiveRecord::Migration
  def self.up
    create_table :units, :id => false do |t|
      t.string :id, :limit => 36, :null => false
      t.string :name, :limit => 100
      t.string :symbol, :limit => 20
      t.boolean :integer, :default => false
      t.boolean :visible, :default => true

      t.string :organisation_id, :limit => 36

      t.timestamps
    end

    add_index(:units, :id)
    add_index(:units, :organisation_id)
  end

  def self.down
    drop_table :units
  end
end
