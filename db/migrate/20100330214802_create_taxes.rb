class CreateTaxes < ActiveRecord::Migration
  def self.up
    create_table :taxes do |t|
      t.string :name
      t.string :abbreviation, :limit => 10
      t.decimal :rate, :precision => 5, :scale => 2


      t.timestamps
    end

  end

  def self.down
    drop_table :taxes
  end
end
