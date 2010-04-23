class CreateTaxes < ActiveRecord::Migration
  def self.up
    create_table :taxes, :id => false do |t|
      t.string :id, :limit => 36, :null => false
      t.string :name
      t.string :abbreviation, :limit => 10
      t.decimal :rate, :precision => 5, :scale => 2

      t.string :organisation_id, :limit => 36

      t.timestamps
    end

    add_index :taxes, :id
    add_index :taxes, :organisation_id
  end

  def self.down
    drop_table :taxes
  end
end
