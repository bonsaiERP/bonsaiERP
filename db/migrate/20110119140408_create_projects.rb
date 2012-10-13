class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.boolean :active, :default => true
      t.date :date_start
      t.date :date_end

      t.text :description

      t.timestamps
    end

    add_index :projects, :active
  end
end
