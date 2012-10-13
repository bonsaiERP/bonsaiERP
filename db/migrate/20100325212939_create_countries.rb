class CreateCountries < ActiveRecord::Migration
  def change
    create_table "common.countries" do |t|
      t.string :name, limit: 50
      t.string :code, limit: 5
      t.string :abbreviation, :limit => 10

      t.timestamps
    end
  end
end
