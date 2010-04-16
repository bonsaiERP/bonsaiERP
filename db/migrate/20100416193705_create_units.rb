class CreateUnits < ActiveRecord::Migration
  def self.up
    create_table :units do |t|
      t.string :name
      t.string :abbreviation
      t.string :description
      t.boolean :integer

      t.integer :organisation_id

      t.timestamps
    end

    add_index(:units, :organisation_id)
  end

  def self.down
    drop_table :units
  end
end
