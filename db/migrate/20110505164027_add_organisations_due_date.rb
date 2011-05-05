class AddOrganisationsDueDate < ActiveRecord::Migration
  def self.up
    add_column :organisations, :due_date, :date
    add_index :organisations, :due_date
  end

  def self.down
    remove_column :organisations, :due_date
  end
end
