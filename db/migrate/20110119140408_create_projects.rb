class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :name
      t.boolean :active
      t.date :date_start
      t.date :date_end
      t.integer :organisation_id, :null => false

      t.timestamps
    end

    add_index :projects, :organisation_id
    add_index :projects, :active

    # For transactions
    add_column :transactions, :project_id, :integer
    add_index :transactions, :project_id
  end

  def self.down
    drop_table :projects
  end
end
