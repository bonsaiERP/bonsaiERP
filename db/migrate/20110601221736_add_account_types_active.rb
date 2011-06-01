class AddAccountTypesActive < ActiveRecord::Migration
  def up
    add_column :account_types, :organisation_id, :integer
    add_column :account_types, :active, :boolean, :default => true

    add_index :account_types, :organisation_id
    add_index :account_types, :active
  end

  def down
    remove_index :account_types, :organisation_id
    remove_index :account_types, :active

    remove_column :account_types, :organisation_id
    remove_column :account_types, :active
  end
end
