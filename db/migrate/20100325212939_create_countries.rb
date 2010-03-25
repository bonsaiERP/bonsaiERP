class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.string :name, :limit => 50
      t.string :abreviation, :limit => 10

      t.timestamps
    end
  end

  def self.down
    drop_table :countries
  end
end
