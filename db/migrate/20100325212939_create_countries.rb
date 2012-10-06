class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table "common.countries" do |t|
      t.string :name, limit: 50
      t.string :code, limit: 5
      t.string :abbreviation, :limit => 10

      t.timestamps
    end
  end

  def self.down
    drop_table :countries
  end
end
