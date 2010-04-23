class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries, :id => false do |t|
      t.string :id, :limit => 36, :null => false
      t.string :name, :limit => 50
      t.string :abbreviation, :limit => 10
      t.text :taxes

      t.timestamps
    end
    add_index(:countries, :id)
  end

  def self.down
    drop_table :countries
  end
end
